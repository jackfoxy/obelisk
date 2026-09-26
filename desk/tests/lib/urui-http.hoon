::  Tests for /lib/urui-http.
::
::  The response shape is a contract with every consuming agent; a change
::  here is a change to every consumer's wire behavior.
::
/+  *test, uhttp=urui-http
|%
::
++  body  (as-octs:mimes:html 'hello')
::
++  payload
  ^-  simple-payload:http
  (respond:uhttp 200 ['text/plain; charset=utf-8' body])
::
++  test-respond-carries-the-status
  =/  sent=simple-payload:http  payload
  =/  missing=simple-payload:http
    (respond:uhttp 404 ['text/plain; charset=utf-8' body])
  ;:  weld
    (expect-eq !>(200) !>(status-code.response-header.sent))
    (expect-eq !>(404) !>(status-code.response-header.missing))
  ==
::
++  test-respond-carries-the-body-octs
  =/  sent=simple-payload:http  payload
  ;:  weld
    (expect !>(?=(^ data.sent)))
    (expect-eq !>(body) !>((need data.sent)))
  ==
::
++  test-require-auth-refuses-an-unauthenticated-request
  =/  sent=simple-payload:http  payload
  =/  refused=simple-payload:http  (require-auth:uhttp | sent [[403 ~] ~])
  ;:  weld
    (expect-eq !>(403) !>(status-code.response-header.refused))
    ::  no body: a refusal must not leak the payload it was guarding
    (expect-eq !>(~) !>(data.refused))
  ==
::
++  test-require-auth-passes-an-authenticated-request-through
  =/  sent=simple-payload:http  payload
  (expect-eq !>(sent) !>((require-auth:uhttp & sent [[403 ~] ~])))
::
++  test-respond-preserves-content-type-and-binary-length
  =/  sent  (respond:uhttp 201 ['application/octet-stream' [4 0x61]])
  ;:  weld
    %+  expect-eq
      !>(~[['content-type' 'application/octet-stream']])
    !>(headers.response-header.sent)
    (expect-eq !>(`[4 0x61]) !>(data.sent))
  ==
::
++  test-auth-refusal-is-consumer-policy
  =/  refused
    (respond:uhttp 401 ['text/plain' (as-octs:mimes:html 'login')])
  (expect-eq !>(refused) !>((require-auth:uhttp | payload refused)))
::
++  assets
  ^-  (list [suffix=@t asset=asset:uhttp])
  :~  ['' 'text/html' [4 'page']]
      ['/' 'text/html' [4 'page']]
      ['/app.js' 'text/javascript; charset=utf-8' [2 'js']]
      ['/ace/theme.js' 'text/javascript' [5 'theme']]
      ['/empty' 'text/plain' [0 0]]
  ==
::
++  test-asset-route-root-and-query
  =/  urls=(list @t)
    ~['/apps/probe' '/apps/probe/' '/apps/probe?x=1' '/apps/probe/?x=1']
  %-  zing
  %+  turn  urls
  |=  url=@t
  %+  expect-eq
    !>(`['text/html' [4 'page']])
  !>((asset-route:uhttp '/apps/probe' url assets))
::
++  test-asset-route-nested-and-query
  ;:  weld
    %+  expect-eq
      !>(`['text/javascript' [5 'theme']])
    !>((asset-route:uhttp '/apps/probe' '/apps/probe/ace/theme.js' assets))
    %+  expect-eq
      !>(`['text/javascript; charset=utf-8' [2 'js']])
    !>((asset-route:uhttp '/apps/probe' '/apps/probe/app.js?v=2' assets))
  ==
::
++  test-asset-route-rejects-nonmatches
  =/  urls=(list @t)
    :~  '/apps/probe-extra/app.js'  '/apps/probe/app.js/extra'
        '/apps/probe/ace/missing.js'  '/apps/probe//app.js'
        '/apps/Probe/app.js'  '/apps/probe/ace/../app.js'
    ==
  %-  zing
  %+  turn  urls
  |=  url=@t
  (expect-eq !>(~) !>((asset-route:uhttp '/apps/probe' url assets)))
::
++  test-asset-route-empty-table-and-body
  ;:  weld
    (expect-eq !>(~) !>((asset-route:uhttp '/apps/probe' '/apps/probe' ~)))
    %+  expect-eq
      !>(`['text/plain' [0 0]])
    !>((asset-route:uhttp '/apps/probe' '/apps/probe/empty' assets))
  ==
::
++  test-asset-route-first-entry-wins
  =/  duplicate=(list [suffix=@t asset=asset:uhttp])
    ~[['/x' 'text/plain' [1 'a']] ['/x' 'text/plain' [1 'b']]]
  %+  expect-eq
    !>(`['text/plain' [1 'a']])
  !>((asset-route:uhttp '/other' '/other/x' duplicate))
--
