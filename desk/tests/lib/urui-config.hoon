::  urui-config: unit tests.
::
/-  urui
/+  *test, config=urui-config
|%
::
++  app
  ^-  app-config:urui
  :*  :*  name=%probe
          title='Probe "App"'
          base='/apps/probe'
          storage-key='probe.session.v2'
          storage-version=2
      ==
      :*  render-debounce=350
          save-debounce=150
          min-explorer=180
          divider=10
          pane-min=25
          pane-max=70
          narrow=760
          max-source=262.144
      ==
      ~[['textTabs' %urui %tabs `%text]]
      ~[['Ctrl-S' 'save' %editor]]
      ~[[%ready 'Ready']]
      docs-root=`'/docs/probe/'
      :*  base='/apps/probe/ace'
          global='probeAce'
          version='1.44.0'
          mode='ace/mode/text'
          light='ace/theme/light'
          dark='ace/theme/dark'
          exts=~['ace/ext/searchbox']
          use-worker=|
      ==
      layout=%rows
      collapse=&
      files=~
  ==
::
++  pinned
  |=  [name=@tas item=band-item:urui]
  ^-  band:urui
  [name [key=~ open=& label=''] item]
::
++  reference-level
  ^-  tab-level:urui
  :*  name=%view
      label='Probe views'
      source=%views
      kind=~
      fixed=~[[%text-files 'Text Files'] [%note-files 'Note Files']]
      add=~
      close=|
      reorder=&
  ==
::
++  editor-level
  ^-  tab-level:urui
  :*  name=%document
      label='Text documents'
      source=%documents
      kind=`%text
      fixed=~
      add=`'New text tab'
      close=&
      reorder=&
  ==
::
++  result-levels
  ^-  (list tab-level:urui)
  :~  :*  name=%view
          label='Result views'
          source=%fixed
          kind=~
          fixed=~[[%results 'Results'] [%messages 'Messages']]
          add=~
          close=|
          reorder=|
      ==
      :*  name=%set
          label='Result sets'
          source=%dynamic
          kind=~
          fixed=~
          add=~
          close=|
          reorder=|
      ==
  ==
::
++  host
  ^-  editor:urui
  :*  id='probe-editor-host'
      label='Probe editor host'
      mode='ace/mode/text'
      wrap=&
      read-only=|
      max-bytes=262.144
  ==
::
++  reference-pane
  ^-  pane:urui
  :*  role=%reference
      id='probe-reference'
      label='Probe reference'
      mode=%read-only
      kind=~
      :~  (pinned %ship [%label 'zod'])
          (pinned %tabs [%tabs ~[reference-level]])
          (pinned %body [%panel 'probe-reference-panel' ~ ~])
      ==
  ==
::
++  editor-pane
  ^-  pane:urui
  :*  role=%editor
      id='probe-editor'
      label='Probe editor'
      mode=%read-write
      kind=`%text
      :~  %+  pinned  %head
          [%heading `'Source' `'probe-status' ~[;button#config-action;]]
          %+  pinned  %controls
          [%controls ~[;button#config-control;]]
          (pinned %tabs [%tabs ~[editor-level]])
          (pinned %body [%panel 'probe-editor-panel' `host ~])
      ==
  ==
::
++  result-pane
  ^-  pane:urui
  :*  role=%result
      id='probe-result'
      label='Probe result'
      mode=%read-write
      kind=~
      :~  :*  name=%tabs
              reveal=[key=`'resultTabs' open=| label='Result tabs']
              item=[%tabs result-levels]
          ==
          (pinned %body [%panel 'probe-result-panel' ~ ~])
      ==
  ==
::
++  spec
  ^-  shell-spec:urui
  :*  app
      brand=~
      toolbar=~
      [reference-pane editor-pane result-pane]
      help=~
      dialogs=~
      styles=~
      scripts=~
  ==
::
++  source  (trip (emit:config spec))
::
++  has
  |=  value=tape
  ^-  ?
  ?=(^ (find value source))
::
++  test-config-emits-valid-assignment
  ;:  weld
    (expect !>((has (trip 'window.URUI_CONFIG = {'))))
    (expect !>((has "};\0a")))
    (expect !>((has "\\\"App\\\"")))
  ==
::
++  test-config-emits-app-identity
  ;:  weld
    (expect !>((has "\"appId\"")))
    (expect !>((has "\"name\":\"probe\"")))
    (expect !>((has "\"storageKey\":\"probe.session.v2\"")))
    (expect !>((has "\"storageVersion\":2")))
  ==
::
++  test-config-emits-no-retired-keys
  ::  Documents are $store data under `files`; nothing else describes them.
  ;:  weld
    (expect-eq !>(%.n) !>((has "\"kinds\"")))
    (expect-eq !>(%.n) !>((has "\"endpoints\"")))
    (expect-eq !>(%.n) !>((has "\"shareParam\"")))
  ==
::
++  test-config-emits-limits
  ;:  weld
    (expect !>((has "\"renderDebounce\":350")))
    (expect !>((has "\"paneMin\":25")))
    (expect !>((has "\"narrow\":760")))
    (expect !>((has "\"maxSource\":262144")))
  ==
::
++  test-config-emits-session-slots
  ;:  weld
    (expect !>((has "\"key\":\"textTabs\"")))
    (expect !>((has "\"owner\":\"urui\"")))
    (expect !>((has "\"shape\":\"tabs\"")))
    (expect !>((has "\"kind\":\"text\"")))
  ==
::
++  test-config-emits-shortcuts-and-statuses
  ;:  weld
    (expect !>((has "\"binding\":\"Ctrl-S\"")))
    (expect !>((has "\"command\":\"save\"")))
    (expect !>((has "\"when\":\"editor\"")))
    (expect !>((has (trip '\22statuses\22:[{'))))
  ==
::
++  test-config-emits-optional-values
  =/  views=tape
    ;:  weld
      (trip '\22permanentViews\22:[{\22label\22:\22Text Files\22,')
      (trip '\22name\22:\22text-files\22},{\22label\22:\22Note Files\22,')
      (trip '\22name\22:\22note-files\22}]')
    ==
  ;:  weld
    (expect !>((has "\"docsRoot\":\"/docs/probe/\"")))
    (expect !>((has views)))
  ==
::
++  test-panes-json
  ;:  weld
    (expect !>((has (trip '\22panes\22:{'))))
    (expect !>((has "\"role\":\"reference\"")))
    (expect !>((has "\"mode\":\"read-only\"")))
    (expect !>((has "\"kind\":null")))
    (expect !>((has "\"kind\":\"label\"")))
    (expect !>((has "\"text\":\"zod\"")))
    (expect !>((has "\"source\":\"views\"")))
    (expect !>((has "\"source\":\"documents\"")))
    (expect !>((has "\"source\":\"fixed\"")))
    (expect !>((has "\"source\":\"dynamic\"")))
    (expect !>((has "\"add\":\"New text tab\"")))
    (expect !>((has "\"kind\":\"heading\"")))
    (expect !>((has "\"statusId\":\"probe-status\"")))
    (expect !>((has "\"kind\":\"controls\"")))
    (expect !>((has "\"kind\":\"panel\"")))
    (expect !>((has "\"id\":\"probe-editor-host\"")))
    (expect !>((has "\"readOnly\":false")))
    (expect !>((has "\"maxBytes\":262144")))
    (expect !>((has "\"key\":\"resultTabs\"")))
    (expect !>((has "\"open\":false")))
    (expect-eq !>(%.n) !>((has "config-action")))
    (expect-eq !>(%.n) !>((has "config-control")))
  ==
::
++  test-config-emits-ace-settings
  ;:  weld
    (expect !>((has (trip '\22ace\22:{'))))
    (expect !>((has "\"global\":\"probeAce\"")))
    (expect !>((has "\"extensions\":[\"ace/ext/searchbox\"]")))
    (expect !>((has "\"useWorker\":false")))
  ==
::
++  probe-files
  ^-  files:urui
  :*  url='/apps/probe/files'
      :~  :*  name=%page
              noun='Page'
              untitled='page'
              starter='# New'
              :~  [/pages ~[%md %txt] `%page &]
                  [/exports ~[%txt] ~ |]
              ==
              preview=`%source
              actions=~[%open %save]
              refs=&
              share=~
      ==  ==
      ~[[view=%page-files store=%page scopes=~]]
  ==
::
++  test-config-emits-files
  ::  Off, the key is null; on, every store and tree field is there.
  ::  `spec` is an arm, so it is bound before %= reaches into it.
  =/  base=shell-spec:urui  spec
  =/  with=shell-spec:urui  base(files.app-config `probe-files)
  =/  text=tape  (trip (emit:config with))
  =/  holds  |=(value=tape ^-(? ?=(^ (find value text))))
  ;:  weld
    (expect !>((has "\"files\":null")))
    (expect !>((holds "\"url\":\"/apps/probe/files\"")))
    (expect !>((holds "\"name\":\"page\"")))
    (expect !>((holds "\"noun\":\"Page\"")))
    (expect !>((holds "\"untitled\":\"page\"")))
    (expect !>((holds "\"starter\":\"# New\"")))
    (expect !>((holds "\"scope\":[\"pages\"]")))
    (expect !>((holds "\"marks\":[\"md\",\"txt\"]")))
    (expect !>((holds "\"ext\":\"page\"")))
    (expect !>((holds "\"ext\":null")))
    (expect !>((holds "\"save\":false")))
    (expect !>((holds "\"preview\":\"source\"")))
    (expect !>((holds "\"actions\":[\"open\",\"save\"]")))
    (expect !>((holds "\"refs\":true")))
    (expect !>((holds "\"share\":null")))
    (expect !>((holds "\"view\":\"page-files\"")))
    (expect !>((holds "\"store\":\"page\"")))
    (expect !>((holds "\"scopes\":[]")))
  ==
::
++  test-config-emits-screen-format-and-collapse
  ;:  weld
    (expect !>((has "\"layout\":\"rows\"")))
    (expect !>((has "\"resultCollapse\":true")))
  ==
--
