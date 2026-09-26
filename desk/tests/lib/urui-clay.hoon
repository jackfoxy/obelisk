/+  *test, clay=urui-clay
|%
  ::  Path policy is independent of the consumer and its HTTP transport.
  ::
++  test-file-path
  =/  cases=(list [raw=@t want=path])
    :~  ['examples/source' /data/probe/examples/source/txt]
        ['/examples/source' /data/probe/examples/source/txt]
        ['///examples/source' /data/probe/examples/source/txt]
        ['examples/source/txt' /data/probe/examples/source/txt]
        ['examples/source/svg' /data/probe/examples/source/svg/txt]
        ['a//b' ~[%data %probe %a %$ %b %txt]]
    ==
  %-  zing
  %+  turn  cases
  |=  [raw=@t want=path]
  (expect-eq !>(`want) !>((file-path:clay /data/probe raw ~[%txt])))
::
++  test-file-svg-extension
  =/  actual  (file-path:clay /data/probe 'output/txt' ~[%svg])
  (expect-eq !>(`/data/probe/output/txt/svg) !>(actual))
::
++  test-invalid-paths
  =/  invalid=(list @t)
    :~  '/'  '///'  '.'  '..'  'a/./b'  'a/../b'
        'a/..'  '../a'  '//../a'  'a b'
    ==
  %-  zing
  %+  turn  invalid
  |=  raw=@t
  ;:  weld
    (expect-eq !>(~) !>((file-path:clay /data/probe raw ~[%txt])))
    (expect-eq !>(~) !>((browse-path:clay /data/probe raw)))
  ==
::
++  test-empty-file-and-extension-list
  ;:  weld
    (expect-eq !>(~) !>((file-path:clay /data/probe '' ~[%txt])))
    (expect-eq !>(~) !>((file-path:clay /data/probe 'source' ~)))
  ==
::
++  test-browse-path
  ;:  weld
    (expect-eq !>(`/data/probe) !>((browse-path:clay /data/probe '')))
    %+  expect-eq
      !>(`/data/probe/examples/source)
    !>((browse-path:clay /data/probe '///examples/source'))
    (expect-eq !>(`/other/root/a) !>((browse-path:clay /other/root 'a')))
    %+  expect-eq
      !>(`~[%data %probe %a %$ %b])
    !>((browse-path:clay /data/probe 'a//b'))
  ==
::
++  test-multiple-extensions
  =/  exts=(list @ta)  ~[%txt %csv %json %md]
  =/  cases=(list [raw=@t want=path])
    :~  ['scripts/query' /data/probe/scripts/query/txt]
        ['results/table/csv' /data/probe/results/table/csv]
        ['results/table/json' /data/probe/results/table/json]
        ['notes/readme/md' /data/probe/notes/readme/md]
        ['results/table/xml' /data/probe/results/table/xml/txt]
    ==
  %-  zing
  %+  turn  cases
  |=  [raw=@t want=path]
  (expect-eq !>(`want) !>((file-path:clay /data/probe raw exts)))
::
++  test-first-extension-is-default
  =/  actual  (file-path:clay /exports 'table' ~[%csv %txt])
  (expect-eq !>(`/exports/table/csv) !>(actual))
::
++  test-body-path
  ::  A body transport adapter decodes its array before calling the lib.
  =/  body  (need (de:json:html '{"path":["results","table","csv"]}'))
  ?>  ?=(%o -.body)
  =/  field  (~(got by p.body) 'path')
  =/  parts=path
    (turn ((ar so):dejs:format field) |=(part=@t ;;(@ta part)))
  =/  raw=@t  (spat parts)
  =/  actual  (file-path:clay /data/probe raw ~[%txt %csv %json])
  (expect-eq !>(`/data/probe/results/table/csv) !>(actual))
::
++  test-browse-json
  ;:  weld
    %+  expect-eq
      !>('{"children":["source","strict-2"],"file":false}')
    !>((en:json:html (browse-json:clay | ~[%source %strict-2])))
    %+  expect-eq
      !>('{"children":[],"file":true}')
    !>((en:json:html (browse-json:clay & ~)))
  ==
--
