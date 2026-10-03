::  Tests for /lib/urui-ace.
::
/-  urui
/+  *test, uace=urui-ace
|%
::
++  spec
  ^-  ace-spec:urui
  :*  base='/apps/probe/ace'
      global='probe-assets'
      version='1.44.0'
      mode='ace/mode/text'
      light='ace/theme/github'
      dark='ace/theme/monokai'
      exts=~['ace/ext/searchbox']
      use-worker=|
  ==
::
++  test-consumer-settings
  =/  source  (trip (config-js:uace spec))
  =/  needles=(list @t)
    :~  'global["probe-assets"]'
        '"basePath":"/apps/probe/ace"'
        '"version":"1.44.0"'
        '"mode":"ace/mode/text"'
        '"lightTheme":"ace/theme/github"'
        '"darkTheme":"ace/theme/monokai"'
        '"extensions":["ace/ext/searchbox"]'
        '"useWorker":false'
    ==
  %-  zing
  %+  turn  needles
  |=  needle=@t
  (expect !>(?=(^ (find (trip needle) source))))
::
++  test-empty-extensions-and-enabled-worker
  =/  input  spec
  =/  source
    (trip (config-js:uace input(exts ~, use-worker &)))
  ;:  weld
    (expect !>(?=(^ (find "\"extensions\":[]" source))))
    (expect !>(?=(^ (find "\"useWorker\":true" source))))
  ==
::
++  test-escaped-configuration
  =/  input  spec
  =/  source
    %-  trip
    %-  config-js:uace
    input(global 'quoted"name', base 'line\0anext\5cpath')
  ;:  weld
    %-  expect
    !>(?=(^ (find (trip 'global["quoted\5c"name"]') source)))
    %-  expect
    !>(?=(^ (find (trip '"basePath":"line\5cnnext\5c\5cpath"') source)))
  ==
--
