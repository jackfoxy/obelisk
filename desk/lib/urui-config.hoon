::  urui-config: $shell-spec -> window.URUI_CONFIG.
::
::  The browser runtime reads every consumer-specific value through this
::  one json object; nothing in urui's javascript names a consumer.
/-  urui
|%
::
++  emit
  ::  Emit `window.URUI_CONFIG = {...};` for one application.
  ::
  |=  spec=shell-spec:urui
  ^-  @t
  %+  rap  3
  :~  'window.URUI_CONFIG = '
      (en:json:html (config-json spec))
      ';\0a'
  ==
::
++  config-json
  |=  spec=shell-spec:urui
  ^-  json
  =/  config  app-config.spec
  =/  panes  panes.spec
  =/  views  (permanent-views reference.panes)
  %-  pairs:enjs:format
  :~  ['appId' (app-id-json app-id.config)]
      ['kinds' a+(turn kinds.config doc-kind-json)]
      ['endpoints' (endpoints-json endpoints.config)]
      ['limits' (limits-json limits.config)]
      ['slots' a+(turn slots.config slot-json)]
      ['shortcuts' a+(turn shortcuts.config shortcut-json)]
      ['statuses' a+(turn statuses.config status-json)]
      ['docsRoot' (unit-text-json docs-root.config)]
      ['shareParam' (share-json share-param.config)]
      ['panes' (panes-json panes)]
      ['permanentViews' a+(turn views view-json)]
      ['ace' (ace-json ace-spec.config)]
      ['layout' s+`@t`layout.config]
      ['resultCollapse' b+collapse.config]
  ==
::
++  panes-json
  |=  [reference=pane:urui editor=pane:urui result=pane:urui]
  ^-  json
  %-  pairs:enjs:format
  :~  ['reference' (pane-json reference)]
      ['editor' (pane-json editor)]
      ['result' (pane-json result)]
  ==
::
++  pane-json
  |=  pane=pane:urui
  ^-  json
  %-  pairs:enjs:format
  :~  ['role' s+`@t`role.pane]
      ['id' s+id.pane]
      ['label' s+label.pane]
      ['mode' s+`@t`mode.pane]
      ['kind' (unit-term-json kind.pane)]
      ['bands' a+(turn bands.pane band-json)]
  ==
::
++  band-json
  |=  band=band:urui
  ^-  json
  %-  pairs:enjs:format
  :~  ['name' s+name.band]
      ['reveal' (reveal-json reveal.band)]
      ['item' (band-item-json item.band)]
  ==
::
++  reveal-json
  |=  value=reveal:urui
  ^-  json
  %-  pairs:enjs:format
  :~  ['key' (unit-text-json key.value)]
      ['open' b+open.value]
      ['label' s+label.value]
  ==
::
++  band-item-json
  |=  item=band-item:urui
  ^-  json
  ?-  -.item
      %label
    %-  pairs:enjs:format
    :~  ['kind' s+'label']
        ['text' s+text.item]
    ==
  ::
      %heading
    %-  pairs:enjs:format
    :~  ['kind' s+'heading']
        ['title' (unit-text-json title.item)]
        ['statusId' (unit-text-json status-id.item)]
    ==
  ::
      %controls
    %-  pairs:enjs:format
    ~[['kind' s+'controls']]
  ::
      %tabs
    %-  pairs:enjs:format
    :~  ['kind' s+'tabs']
        ['levels' a+(turn levels.item tab-level-json)]
    ==
  ::
      %panel
    %-  pairs:enjs:format
    :~  ['kind' s+'panel']
        ['id' s+id.item]
        ['host' (unit-editor-json host.item)]
    ==
  ==
::
++  tab-level-json
  |=  level=tab-level:urui
  ^-  json
  %-  pairs:enjs:format
  :~  ['name' s+name.level]
      ['label' s+label.level]
      ['source' s+`@t`source.level]
      ['kind' (unit-term-json kind.level)]
      ['fixed' a+(turn fixed.level view-json)]
      ['add' (unit-text-json add.level)]
      ['close' b+close.level]
      ['reorder' b+reorder.level]
  ==
::
++  unit-editor-json
  |=  value=(unit editor:urui)
  ^-  json
  ?~  value  ~
  (editor-json u.value)
::
++  editor-json
  |=  editor=editor:urui
  ^-  json
  %-  pairs:enjs:format
  :~  ['id' s+id.editor]
      ['label' s+label.editor]
      ['mode' s+mode.editor]
      ['wrap' b+wrap.editor]
      ['readOnly' b+read-only.editor]
      ['maxBytes' (number max-bytes.editor)]
  ==
::
++  permanent-views
  ::  The first %views level in the reference pane seeds the explorer.
  |=  pane=pane:urui
  ^-  (list [@tas @t])
  =/  bands=(list band:urui)  bands.pane
  |-
  ?~  bands  ~
  ?.  ?=([%tabs *] item.i.bands)
    $(bands t.bands)
  (views-level levels.item.i.bands)
::
++  views-level
  |=  levels=(list tab-level:urui)
  ^-  (list [@tas @t])
  ?~  levels  ~
  ?:  =(%views source.i.levels)  fixed.i.levels
  $(levels t.levels)
::
++  app-id-json
  |=  id=app-id:urui
  ^-  json
  %-  pairs:enjs:format
  :~  ['name' s+name.id]
      ['title' s+title.id]
      ['base' s+base.id]
      ['storageKey' s+storage-key.id]
      ['storageVersion' (number storage-version.id)]
  ==
::
++  doc-kind-json
  |=  kind=doc-kind:urui
  ^-  json
  %-  pairs:enjs:format
  :~  ['name' s+name.kind]
      ['label' s+label.kind]
      ['untitled' s+untitled.kind]
      ['ext' s+ext.kind]
      ['leaf' s+leaf.kind]
      ['mime' s+mime.kind]
      ['tabs' b+tabs.kind]
      ['refs' b+refs.kind]
  ==
::
++  endpoints-json
  |=  endpoints=endpoints:urui
  ^-  json
  %-  pairs:enjs:format
  :~  ['transport' s+`@t`transport.endpoints]
      ['pathHeader' (unit-text-json path-header.endpoints)]
      ['flagHeader' (unit-text-json flag-header.endpoints)]
      ['browse' s+browse.endpoints]
      ['load' s+load.endpoints]
      ['save' s+save.endpoints]
      ['delete' s+delete.endpoints]
  ==
::
++  limits-json
  |=  limits=limits:urui
  ^-  json
  %-  pairs:enjs:format
  :~  ['renderDebounce' (number render-debounce.limits)]
      ['saveDebounce' (number save-debounce.limits)]
      ['minExplorer' (number min-explorer.limits)]
      ['divider' (number divider.limits)]
      ['paneMin' (number pane-min.limits)]
      ['paneMax' (number pane-max.limits)]
      ['narrow' (number narrow.limits)]
      ['maxSource' (number max-source.limits)]
  ==
::
++  slot-json
  |=  slot=slot:urui
  ^-  json
  %-  pairs:enjs:format
  :~  ['key' s+key.slot]
      ['owner' s+`@t`owner.slot]
      ['shape' s+`@t`shape.slot]
      ['kind' (unit-term-json kind.slot)]
  ==
::
++  shortcut-json
  |=  shortcut=shortcut:urui
  ^-  json
  %-  pairs:enjs:format
  :~  ['binding' s+binding.shortcut]
      ['command' s+command.shortcut]
      ['when' s+`@t`when.shortcut]
  ==
::
++  status-json
  |=  [name=@tas label=@t]
  ^-  json
  %-  pairs:enjs:format
  ~[['name' s+name] ['label' s+label]]
::
++  view-json
  |=  [name=@tas label=@t]
  ^-  json
  %-  pairs:enjs:format
  ~[['name' s+name] ['label' s+label]]
::
++  share-json
  |=  share=(unit [name=@t max=@ud param-max=@ud])
  ^-  json
  ?~  share  ~
  %-  pairs:enjs:format
  :~  ['name' s+name.u.share]
      ['max' (number max.u.share)]
      ['paramMax' (number param-max.u.share)]
  ==
::
++  ace-json
  |=  ace=ace-spec:urui
  ^-  json
  %-  pairs:enjs:format
  :~  ['base' s+base.ace]
      ['global' s+global.ace]
      ['version' s+version.ace]
      ['mode' s+mode.ace]
      ['light' s+light.ace]
      ['dark' s+dark.ace]
      ['extensions' a+(turn exts.ace |=(ext=@t s+ext))]
      ['useWorker' b+use-worker.ace]
  ==
::
++  unit-text-json
  |=  value=(unit @t)
  ^-  json
  ?~(value ~ s+u.value)
::
++  unit-term-json
  |=  value=(unit @tas)
  ^-  json
  ?~(value ~ s+u.value)
::
++  number
  ::  `scot %ud` groups digits with dots, which json numbers cannot carry.
  |=  value=@ud
  ^-  json
  =/  digits
    %+  skim  (trip (scot %ud value))
    |=(char=@tD !=('.' char))
  n+(crip digits)
--
