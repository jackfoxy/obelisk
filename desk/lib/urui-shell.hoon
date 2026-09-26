::  urui-shell: the Sail frame, built from a $shell-spec.
::
::  urui owns the document, header, explorer, pane frames, resizers, tab
::  strips, help panel, dialogs, and asset tags.  Consumer marl is spliced
::  into the named slots without interpretation.
::
::  A $pane is an ordered stack of bands and ++pane walks that stack,
::  dispatching on each $band-item.  Band order is the whole layout
::  language: a %heading listed before the %tabs band is a heading above
::  the tabs, listed after it a heading below them.  Every derived id
::  follows one scheme — `{pane}-{band}` on a band, `{pane}-{band}-toggle`
::  on its reveal control, `{pane}-{level}-tabs` on a depth-0 tab strip.
::
/-  urui
/+  ujs=urui-js
|%
::
++  build
  ::  The whole document for one application.
  ::
  ::  The full frame is the one with an explorer, and the explorer is a
  ::  reference pane whose tab band carries a %views level.  A spec
  ::  without one gets the compact frame.
  ::
  ::  Example:
  ::    ++  page  (build:shell spec)
  |=  spec=shell-spec:urui
  ^-  manx
  ?:  (has-views reference.panes.spec)
    (full spec)
  (compact spec)
::
++  has-views
  ::  Does this pane's tab band carry a %views level?
  |=  =pane:urui
  ^-  ?
  %+  lien  bands.pane
  |=  =band:urui
  ^-  ?
  ?.  ?=([%tabs *] item.band)  |
  %+  lien  levels.item.band
  |=(level=tab-level:urui =(%views source.level))
::
++  full
  ::  Full application shell with explorer, workspace, and dialogs.
  |=  spec=shell-spec:urui
  ^-  manx
  =/  config  app-config.spec
  =/  id  app-id.config
  =/  style-tags=marl
    %+  turn  styles.spec
    style-tag
  =/  script-tags=marl
    %+  turn  scripts.spec
    |=  src=@t
    ^-  manx
    ;script(src (trip src));
  =/  theme-js
    (theme-bootstrap:ujs storage-key.id storage-version.id)
  =/  orientation=tape
    ?:(=(%rows layout.config) "horizontal" "vertical")
  =/  boot=marl
    :~  ;script
          ;+  ;/  (trip theme-js)
        ==
    ==
  ;html
    ;head
      ;meta(charset "utf-8");
      ;meta(name "viewport", content "width=device-width, initial-scale=1");
      ;title:"{(trip title.id)}"
      ;*  boot
      ;*  style-tags
    ==
    ;body
      ;header.app-header
        ;*  brand.spec
        ;+  settings-button
        ;*  toolbar.spec
      ==
      ;main#workbench.workbench
        ;+  (pane reference.panes.spec config)
        ;button#explorer-resizer.explorer-resizer
          =type              "button"
          =role              "separator"
          =aria-orientation  "vertical"
          =aria-label        "Resize explorer"
          ;span.sr-only: Resize explorer
        ==
        ;section#workspace.workspace(data-layout (trip layout.config))
          ;+  (pane editor.panes.spec config)
          ;div#splitter.splitter
            =role              "separator"
            =tabindex          "0"
            =aria-orientation  orientation
            =aria-label        "Resize editor and preview"
            ;span.sr-only: Resize editor and preview
          ==
          ;+  (pane result.panes.spec config)
        ==
      ==
      ;+  settings-modal
      ;+  (help-panel spec)
      ;+  context-menu
      ;+  error-dialog
      ;*  (extra-dialogs dialogs.spec)
      ;*  script-tags
    ==
  ==
::
++  compact
  ::  Three-pane frame for applications with no explorer.
  |=  spec=shell-spec:urui
  ^-  manx
  =/  config  app-config.spec
  =/  id  app-id.config
  =/  style-tags=marl
    %+  turn  styles.spec
    style-tag
  =/  script-tags=marl
    %+  turn  scripts.spec
    |=  src=@t
    ^-  manx
    ;script(src (trip src));
  ;html
    ;head
      ;meta(charset "utf-8");
      ;meta(name "viewport", content "width=device-width, initial-scale=1");
      ;title:"{(trip title.id)}"
      ;*  style-tags
    ==
    ;body(data-app (trip name.id))
      ;header.app-header
        ;*  brand.spec
        ;div.toolbar
          ;+  settings-button
          ;*  toolbar.spec
        ==
      ==
      ;main.app-shell
        ;+  (pane reference.panes.spec config)
        ;+  (pane editor.panes.spec config)
        ;+  (pane result.panes.spec config)
      ==
      ;+  settings-modal
      ;div.app-dialogs
        ;*  dialogs.spec
      ==
      ;div.app-help(hidden "")
        ;*  help.spec
      ==
      ;*  script-tags
    ==
  ==
::
++  style-tag
  ::  Absolute paths are stylesheet links; other cords are inline CSS.
  |=  value=@t
  ^-  manx
  =/  chars  (trip value)
  ?:  ?&(?=(^ chars) =('/' i.chars))
    ;link(rel "stylesheet", href (trip value));
  ;style
    ;+  ;/  chars
  ==
::
++  pane
  ::  One pane: its bands, stacked in the order the consumer gave them.
  ::
  ::  A pane with a %views level is the explorer aside; every other pane
  ::  is a section.  `data-role` is what the runtime finds a pane by and
  ::  `data-mode` is what forbids it a `+` control, so both shapes carry
  ::  the pair.
  |=  [=pane:urui config=app-config:urui]
  ^-  manx
  =/  nodes=marl  (pane-bands pane config)
  =/  pane-id  (trip id.pane)
  =/  pane-label  (trip label.pane)
  =/  as-role  (trip role.pane)
  =/  as-mode  (trip mode.pane)
  ?:  (has-views pane)
    ;aside.explorer-pane
      =id           pane-id
      =role         "region"
      =aria-label   pane-label
      =data-role    as-role
      =data-mode    as-mode
      ;*  nodes
    ==
  ;section
    =id          pane-id
    =class       (pane-class role.pane)
    =role        "region"
    =aria-label  pane-label
    =data-role   as-role
    =data-mode   as-mode
    ;*  nodes
  ==
::
++  pane-class
  ::  The frame classes the stylesheet already names.  The result pane
  ::  is `.preview-pane`: it is the preview in every consumer so far, and
  ::  renaming it would move css that %shell and two consumers share.
  |=  =pane-role:urui
  ^-  tape
  ?-  pane-role
    %reference  "pane reference-pane"
    %editor     "pane editor-pane"
    %result     "pane preview-pane"
  ==
::
++  pane-bands
  |=  [=pane:urui config=app-config:urui]
  ^-  marl
  ?~  bands.pane  ~
  %+  weld  (band-nodes pane i.bands.pane config)
  $(bands.pane t.bands.pane)
::
++  band-nodes
  ::  One band: its reveal toggle, when it has one, and then the band.
  ::
  ::  The toggle is the band's sibling rather than its child, because a
  ::  hidden band would otherwise hide the only control that reveals it.
  ::  A band with `key=~` is pinned open and renders no toggle at all.
  |=  [=pane:urui =band:urui config=app-config:urui]
  ^-  marl
  =/  wrapper-id  (trip (joined id.pane `@t`name.band))
  =/  wrapper-class  "pane-band {(item-class item.band)}"
  =/  band-name  (trip name.band)
  =/  inner=marl  (item-nodes pane band config)
  =/  wrapper=manx
    ?:  open.reveal.band
      ;div(class wrapper-class, id wrapper-id, data-band band-name)
        ;*  inner
      ==
    ;div(class wrapper-class, id wrapper-id, data-band band-name, hidden "")
      ;*  inner
    ==
  ?~  key.reveal.band  ~[wrapper]
  :~  (band-toggle wrapper-id reveal.band)
      wrapper
  ==
::
++  item-class
  ::  The band wrapper's second class, by item shape.  A %heading band is
  ::  `.pane-header` itself: the header is one band, not a band around
  ::  one.
  |=  item=band-item:urui
  ^-  tape
  ?-  -.item
    %label     "pane-band-label"
    %heading   "pane-header"
    %controls  "pane-band-controls"
    %tabs      "pane-band-tabs"
    %panel     "pane-band-panel"
  ==
::
++  band-toggle
  ::  `{pane}-{band}-toggle`, controlling the band it precedes.  The
  ::  glyph is the stylesheet's; the accessible name is the consumer's.
  |=  [wrapper-id=tape =reveal:urui]
  ^-  manx
  =/  toggle-id  "{wrapper-id}-toggle"
  =/  toggle-label  (trip label.reveal)
  ?:  open.reveal
    ;button.icon-button.band-toggle
      =id             toggle-id
      =type           "button"
      =aria-controls  wrapper-id
      =aria-expanded  "true"
      =title          toggle-label
      ;span.sr-only:"{toggle-label}"
    ==
  ;button.icon-button.band-toggle
    =id             toggle-id
    =type           "button"
    =aria-controls  wrapper-id
    =aria-expanded  "false"
    =title          toggle-label
    ;span.sr-only:"{toggle-label}"
  ==
::
++  item-nodes
  ::  One band's contents.  A %controls band's marl is spliced bare: the
  ::  wrapper is already the row, and a second div would be a layer the
  ::  consumer cannot name.
  |=  [=pane:urui =band:urui config=app-config:urui]
  ^-  marl
  ?-  -.item.band
      %label
    :~  ;span.pane-label:"{(trip text.item.band)}"
    ==
  ::
      %heading
    %:  heading-band
      pane
      title.item.band
      status-id.item.band
      actions.item.band
      config
    ==
  ::
      %controls  marl.item.band
      %tabs      (tabs-band pane levels.item.band config)
  ::
      %panel
    %:  panel-band
      id.item.band
      host.item.band
      body.item.band
    ==
  ==
::
++  heading-band
  ::  Title, status line, and right-justified actions.
  ::
  ::  An editor pane's title carries `{kind}-source-heading`: the id an
  ::  Ace host labels itself by, and the one id in the shell derived from
  ::  a $doc-kind rather than from a band.
  |=  $:  =pane:urui
          title=(unit @t)
          status-id=(unit @t)
          actions=marl
          config=app-config:urui
      ==
  ^-  marl
  =/  titled=marl
    ?~  title  ~
    ?:  ?&(=(%editor role.pane) ?=(^ kind.pane))
      =/  heading-id  (trip (joined `@t`u.kind.pane 'source-heading'))
      :~  ;h2.pane-title(id heading-id):"{(trip u.title)}"
      ==
    :~  ;h2.pane-title:"{(trip u.title)}"
    ==
  =/  status=marl
    ?~  status-id  ~
    :~  ;span.status.pane-status
          =id    (trip u.status-id)
          =role  "status"
          ;+  ;/  (trip (initial-status role.pane statuses.config))
        ==
    ==
  ::  the collapse control is the last action, so it sits hard right
  ::  with the consumer's own actions rather than as a fourth child
  =/  all-actions=marl
    ?.  ?&(collapse.config =(%result role.pane))  actions
    (snoc actions (result-collapse label.pane layout.config))
  =/  acted=marl
    ?~  all-actions  ~
    :~  ;div.pane-actions
          ;*  all-actions
        ==
    ==
  ;:  weld  titled  status  acted  ==
::
++  result-collapse
  ::  `#result-collapse`, drawn expanded.  The glyph points the way the
  ::  pane will go: down under %rows, right under %columns; the runtime
  ::  redraws it whenever the format or the state changes.
  |=  [label=@t layout=screen-format:urui]
  ^-  manx
  ;button#result-collapse.icon-button.result-collapse
    =type           "button"
    =aria-label     "Collapse {(trip label)}"
    =aria-expanded  "true"
    ;+  ;/  ?:(=(%rows layout) "⌄" "›")
  ==
::
++  panel-band
  ::  The tab panel: the Ace host urui manages, then the consumer's own
  ::  marl.  Deeper tab strips are generated into this element by the
  ::  runtime, so its id is the one a consumer addresses a panel by.
  ::
  ::  `panel` is cast before ++weld sees it: weld casts its product to
  ::  its second argument, so a bare Sail literal there would be the type
  ::  the Ace host has to nest in.
  |=  [id=@t host=(unit editor:urui) body=marl]
  ^-  marl
  =/  panel=marl
    :~  ;div.pane-body(id (trip id))
          ;*  body
        ==
    ==
  (weld (editor-host host) panel)
::
++  editor-host
  ::  An Ace host is an empty `.editor-host` carrying the mode; the
  ::  adapter the consumer builds mounts into it by id.  The hidden span
  ::  is there because a tall-attribute element must have children.
  |=  value=(unit editor:urui)
  ^-  marl
  ?~  value  ~
  =/  host  u.value
  :~  ;div.editor-host
        =id          (trip id.host)
        =aria-label  (trip label.host)
        =data-mode   (trip mode.host)
        ;span(hidden "");
      ==
  ==
::
++  tabs-band
  ::  The depth-0 strip, and only that one.  Deeper levels are config the
  ::  runtime reads: it generates their strips inside the active panel of
  ::  the level above, once per open parent tab.
  |=  [=pane:urui levels=(list tab-level:urui) config=app-config:urui]
  ^-  marl
  ?~  levels  ~
  ?:  =(%views source.i.levels)
    (views-strip pane i.levels config)
  :~  (tab-strip pane i.levels)
  ==
::
++  tab-strip
  ::  `{pane}-{level}-tabs`, empty: every strip but the explorer's is
  ::  filled by the runtime, which needs the session before it can know
  ::  what the tabs are.  The hidden span is there because a
  ::  tall-attribute element must have children.
  ::
  ::  `.document-tabs` rides along with `.tab-strip` until %tabs css
  ::  moves to `[data-depth]`; the two name the same strip.
  |=  [=pane:urui level=tab-level:urui]
  ^-  manx
  ;div.tab-strip.document-tabs
    =id           (trip (strip-id id.pane name.level))
    =role         "tablist"
    =aria-label   (trip label.level)
    =data-depth   "0"
    =data-source  (trip `@t`source.level)
    ;span(hidden "");
  ==
::
++  views-strip
  ::  The explorer: the seeded strip, the collapse control urui owns, and
  ::  one panel per seeded view.
  ::
  ::  `fixed` seeds the strip and the runtime appends documentation and
  ::  reference tabs to it, keyed by view name — so a view renamed here
  ::  is a view the session drops.
  |=  [=pane:urui level=tab-level:urui config=app-config:urui]
  ^-  marl
  =/  header=manx
    ;div.explorer-header
      ;div.explorer-tabs
        =id           (trip (strip-id id.pane name.level))
        =role         "tablist"
        =aria-label   (trip label.level)
        =data-depth   "0"
        =data-source  "views"
        ;*  (explorer-tabs fixed.level &)
      ==
      ;button#explorer-collapse.icon-button.explorer-collapse
        =type           "button"
        =aria-label     "Collapse explorer"
        =aria-expanded  "true"
        ‹
      ==
    ==
  :-  header
  (explorer-panels fixed.level kinds.config &)
::
++  explorer-tabs
  ::  Ids are derived from the view name — `{view}-tab` controlling
  ::  `{view}-panel` — and the first view is the selected one.  The
  ::  runtime re-orders, re-labels, and adds to this strip by those
  ::  names, so a view renamed here is a view the session drops.
  |=  [views=(list [@tas @t]) first=?]
  ^-  marl
  ?~  views  ~
  =/  [name=@tas label=@t]  i.views
  =/  view  `@t`name
  =/  tab-id  (cat 3 view '-tab')
  =/  panel-id  (cat 3 view '-panel')
  =/  wrap-class
    ?:  first  "explorer-tab-control active"
    "explorer-tab-control"
  =/  tab=manx
    ?:  first
      ;button.explorer-tab.active
        =id                  (trip tab-id)
        =type                "button"
        =role                "tab"
        =data-explorer-view  (trip view)
        =aria-selected       "true"
        =aria-controls       (trip panel-id)
        {(trip label)}
      ==
    ;button.explorer-tab
      =id                  (trip tab-id)
      =type                "button"
      =role                "tab"
      =data-explorer-view  (trip view)
      =aria-selected       "false"
      =aria-controls       (trip panel-id)
      =tabindex            "-1"
      {(trip label)}
    ==
  :-  ;div(class wrap-class, role "presentation")
        ;+  tab
      ==
  $(views t.views, first |)
::
++  explorer-panels
  ::  Each seeded view gets one file tree, `{view}-tree`, labelled after
  ::  the $doc-kind in the same position: the first view owns the first
  ::  kind.  `aria-busy` stays true until the runtime's first browse
  ::  response replaces the placeholder.
  |=  [views=(list [@tas @t]) kinds=(list doc-kind:urui) first=?]
  ^-  marl
  ?~  views  ~
  =/  [name=@tas label=@t]  i.views
  =/  view  `@t`name
  =/  tab-id  (cat 3 view '-tab')
  =/  panel-id  (cat 3 view '-panel')
  =/  tree-id  (cat 3 view '-tree')
  =/  tree-label=@t
    ?~  kinds  label
    (cat 3 label.i.kinds ' files')
  =/  tree=manx
    ;div.explorer-file-tree
      =id          (trip tree-id)
      =role        "tree"
      =aria-label  (trip tree-label)
      =aria-busy   "true"
      ;p: Loading…
    ==
  =/  panel=manx
    ?:  first
      ;div.explorer-panel
        =id               (trip panel-id)
        =role             "tabpanel"
        =aria-labelledby  (trip tab-id)
        ;+  tree
      ==
    ;div.explorer-panel
      =id               (trip panel-id)
      =hidden           ""
      =role             "tabpanel"
      =aria-labelledby  (trip tab-id)
      ;+  tree
    ==
  :-  panel
  $(views t.views, kinds ?~(kinds ~ t.kinds), first |)
::
++  settings-button
  ::  Frame furniture, emitted before the consumer's toolbar marl so it
  ::  sits left of whatever the consumer puts there.
  ^-  manx
  ;button#settings.settings-button
    =type           "button"
    =aria-expanded  "false"
    =aria-haspopup  "dialog"
    =title          "Settings"
    ;span: Settings
  ==
::
++  layout-glyph
  ::  The screen-format pictograms are css boxes, not images: they take
  ::  the frame's own border and accent colours in either theme.
  |=  name=tape
  ^-  manx
  ;span
    =class        "layout-glyph layout-glyph-{name}"
    =aria-hidden  "true"
    ;i.glyph-cell.glyph-a;
    ;i.glyph-cell.glyph-b;
    ;i.glyph-cell.glyph-c;
  ==
::
++  layout-choice
  ::  `name` is the value ++setLayout applies and persists.
  |=  [name=tape label=tape]
  ^-  manx
  ;button
    =type          "button"
    =class         "layout-choice"
    =id            "layout-{name}"
    =data-layout   name
    =aria-pressed  "false"
    =title         label
    =aria-label    label
    ;+  (layout-glyph name)
  ==
::
++  settings-modal
  ::  urui-owned preferences. The theme control lives here, at the same
  ::  `#theme` id the runtime has always bound, so moving it out of a
  ::  consumer toolbar changes markup and nothing else.
  ^-  manx
  ;aside#settings-modal.help-panel
    =hidden           ""
    =role             "dialog"
    =aria-modal       "true"
    =aria-labelledby  "settings-title"
    ;div.help-card.settings-card
      ;div.pane-header
        ;h2#settings-title: Settings
        ;button#close-settings.icon-button.help-close
          =type        "button"
          =title       "Close"
          =aria-label  "Close settings"
          ;span.close-icon(aria-hidden "true");
        ==
      ==
      ;label.settings-field
        ;span.settings-label: Theme
        ;select#theme(aria-label "Theme")
          ;option(value "system"): System
          ;option(value "light"): Light
          ;option(value "dark"): Dark
        ==
      ==
      ;fieldset.settings-field.settings-keys
        ;legend.settings-label: Keybindings
        ;label.preference
          ;input#keys-ace(type "radio", name "keybindings", value "ace");
          ;span: Ace keybindings
        ==
        ;label.preference
          ;input#keys-vim(type "radio", name "keybindings", value "vim");
          ;span: Vim keybindings
        ==
      ==
      ;div.settings-field
        ;span#screen-format-label.settings-label: Screen format
        ;div.layout-choices
          =role             "group"
          =aria-labelledby  "screen-format-label"
          ;+  %+  layout-choice  "columns"
              "Reference, editor and render side by side"
          ;+  %+  layout-choice  "rows"
              "Reference beside editor stacked over render"
        ==
      ==
    ==
  ==
::
++  help-panel
  |=  spec=shell-spec:urui
  ^-  manx
  ;aside#help-panel.help-panel
    =hidden          ""
    =role            "dialog"
    =aria-modal      "true"
    =aria-labelledby  "help-title"
    ;div#editor-help-card.help-card.editor-help-card
      ;div.pane-header
        ;h2#help-title: Help
        ;button#close-help.icon-button.help-close
          =type        "button"
          =title       "Close"
          =aria-label  "Close help"
          ;span.close-icon(aria-hidden "true");
        ==
      ==
      ;*  help.spec
    ==
  ==
::
++  context-menu
  ::  One menu for the whole page, at ids the runtime's file tree binds.
  ^-  manx
  ;div#file-context-menu.file-context-menu(hidden "", role "menu")
    ;button#file-context-open(type "button", role "menuitem"): Open
    ;button#file-context-delete.danger-button
      =type  "button"
      =role  "menuitem"
      Delete
    ==
  ==
::
++  error-dialog
  ::  The Clay failure modal, at ids the runtime's error path binds.
  ^-  manx
  ;aside#clay-error-modal.help-panel
    =hidden          ""
    =role            "dialog"
    =aria-modal      "true"
    =aria-labelledby  "clay-error-title"
    ;div.help-card
      ;div.pane-header
        ;h2#clay-error-title: Clay error
        ;button#close-clay-error
          =type        "button"
          =aria-label  "Close Clay error"
          ;span: Close
        ==
      ==
      ;pre#clay-error-message.clay-error-message;
    ==
  ==
::
++  extra-dialogs
  |=  dialogs=marl
  ^-  marl
  ?~  dialogs  ~
  :~  ;div.app-dialogs
        ;*  dialogs
      ==
  ==
::
++  initial-status
  ::  The editor pane starts on the vocabulary's first status
  ::  (conventionally "ready"); every other pane starts on the third
  ::  (conventionally "empty") — a fixed position in the consumer's own
  ::  status list, not something urui can name generically.
  |=  [role=pane-role:urui statuses=(list [@tas @t])]
  ^-  @t
  ?~  statuses  ''
  =/  first-label=@t  +.i.statuses
  ?:  =(%editor role)  first-label
  =/  rest  t.statuses
  ?~  rest  first-label
  =/  rest  t.rest
  ?~  rest  first-label
  +.i.rest
::
++  joined
  ::  `{a}-{b}`, the one way the shell derives an id from two names.
  |=  [a=@t b=@t]
  ^-  @t
  (rap 3 ~[a '-' b])
::
++  strip-id
  ::  `{pane}-{level}-tabs`, the id every depth-0 tab strip carries.
  |=  [pane-id=@t level=@tas]
  ^-  @t
  (rap 3 ~[pane-id '-' `@t`level '-tabs'])
--
