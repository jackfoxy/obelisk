::  Tests for %obelisk-web shared types and state lifecycle.
::
/-  ast=obelisk-ast, web=obelisk-web
/+  json-lib=obelisk-web-json, state=obelisk-web, *test
/=  agent  /app/obelisk-web
|%
::
++  queued-fixture
  ^-  queued-request:web
  :*  request-id=41
      eyre-id=~.obelisk-web-test
      received-at=~2026.8.1
      request=[%run %sys 'SELECT 1;']
  ==
::
++  active-fixture
  ^-  active-obelisk:web
  :*  job=queued-fixture
      action=`action:ast`[%parse %sys "SELECT 1;"]
      work-kind=%parse
      reply-kind=%parse
      phase=%waiting
      obelisk-wire=/obelisk-web/obelisk/41
      timeout-wire=/obelisk-web/timeout/41
      retries=2
  ==
::
++  dirty-transient-fixture
  ^-  transient-state:web
  :*  binding=%bound
      next-request-id=42
      queue=~[queued-fixture]
      active=`active-fixture
  ==
::
++  test-state-bunts-00
  ;:  weld
    %+  expect-eq
      !>(*durable-state:web)
    !>(empty-durable-state:state)
  ::
    %+  expect-eq
      !>(*saved-state-0:web)
    !>(empty-saved-state:state)
  ::
    %+  expect-eq
      !>(*transient-state:web)
    !>(empty-transient-state:state)
  ::
    %+  expect-eq
      !>(*live-state:web)
    !>(empty-live-state:state)
  ==
::
++  test-state-construction-01
  %+  expect-eq
    !>(`live-state:web`[%0 ~ [%unbound 0 ~ ~]])
  !>(empty-live-state:state)
::
++  test-save-load-roundtrip-02
  =/  live=live-state:web
    empty-live-state:state
  =.  transient.live  dirty-transient-fixture
  =/  saved=saved-state-0:web  (save-state:state live)
  =/  loaded=live-state:web  (load-state:state saved)
  ;:  weld
    %+  expect-eq
      !>(empty-saved-state:state)
    !>(saved)
  ::
    %+  expect-eq
      !>(saved)
    !>((save-state:state loaded))
  ==
::
++  test-load-reinitializes-transient-03
  =/  live=live-state:web
    empty-live-state:state
  =.  transient.live  dirty-transient-fixture
  =/  loaded=live-state:web
    (load-state:state (save-state:state live))
  %+  expect-eq
    !>(empty-transient-state:state)
  !>(transient.loaded)
::
++  test-load-vase-roundtrip-04
  =/  loaded=(each live-state:web tang)
    (load-vase:state !>(empty-saved-state:state))
  ?-  -.loaded
    %.n  (expect !>(%.n))
    %.y
      %+  expect-eq
        !>(empty-live-state:state)
      !>(p.loaded)
  ==
::
++  test-load-vase-rejects-corrupt-05
  =/  loaded=(each live-state:web tang)
    (load-vase:state !>([%not-an-obelisk-web-state ~]))
  (expect !>(?=(%.n -.loaded)))
::
++  bowl
  ^-  bowl:gall
  %*  .  *bowl:gall
    our  ~zod
    src  ~zod
    dap  %obelisk-web
    byk  [~zod %obelisk %da ~2026.8.1]
  ==
::
++  request
  |=  [method=method:http url=@t]
  ^-  inbound-request:eyre
  %*  .  *inbound-request:eyre
    authenticated  %.y
    request
      %*  .  *request:http
        method  method
        url     url
      ==
  ==
::
++  api-request
  |=  $:  url=@t
          authenticated=?
          body=(unit @t)
          content-type=(unit @t)
      ==
  ^-  inbound-request:eyre
  =/  req  (request %'POST' url)
  =.  authenticated.req  authenticated
  =.  body.request.req
    ?~  body  ~
    `(as-octt:mimes:html (trip u.body))
  =.  header-list.request.req
    ?~  content-type  ~
    ~[['content-type' u.content-type]]
  req
::
++  request-text
  |=  req=web-request:web
  ^-  @t
  (json-text:json-lib (request-json:json-lib req))
::
++  hostile-text
  ^-  @t
  =/  first
    (cat 3 '<script>alert("obelisk")</script> & / \\' '\0a')
  (cat 3 first 'snowman: ☃')
::
++  foreign-bowl
  ^-  bowl:gall
  =/  local=bowl:gall  bowl
  local(src ~nec)
::
++  poke-http
  |=  req=inbound-request:eyre
  ^-  (quip card:agent:gall agent:gall)
  %-  on-poke:~(. agent bowl)
  [%handle-http-request !>(['request' req])]
::
++  poke-http-with
  |=  [req=inbound-request:eyre =bowl:gall]
  ^-  (quip card:agent:gall agent:gall)
  %-  on-poke:~(. agent bowl)
  [%handle-http-request !>(['request' req])]
::
++  response-status
  |=  cards=(list card:agent:gall)
  ^-  @ud
  ?>  ?=(^ cards)
  =/  card  i.cards
  ?>  ?=(%give -.card)
  =/  gift  p.card
  ?>  ?=(%fact -.gift)
  ?>  =(%http-response-header p.cage.gift)
  =/  header  !<(response-header:http q.cage.gift)
  status-code.header
::
++  response-headers
  |=  cards=(list card:agent:gall)
  ^-  (list [key=@t value=@t])
  ?>  ?=(^ cards)
  =/  card  i.cards
  ?>  ?=(%give -.card)
  =/  gift  p.card
  ?>  ?=(%fact -.gift)
  ?>  =(%http-response-header p.cage.gift)
  =/  header  !<(response-header:http q.cage.gift)
  headers.header
::
++  response-body
  |=  cards=(list card:agent:gall)
  ^-  @t
  ?>  ?=(^ cards)
  =/  cards  t.cards
  ?>  ?=(^ cards)
  =/  card  i.cards
  ?>  ?=(%give -.card)
  =/  gift  p.card
  ?>  ?=(%fact -.gift)
  ?>  =(%http-response-data p.cage.gift)
  =/  data  !<((unit octs) q.cage.gift)
  q:(need data)
::
++  response-json
  |=  cards=(list card:agent:gall)
  ^-  json
  (need (de:json:html (response-body cards)))
::
++  response-error-code
  |=  cards=(list card:agent:gall)
  ^-  @t
  =/  jon=json  (response-json cards)
  =/  error=json  (need (field:json-lib 'error' jon))
  (need (text-field:json-lib 'code' error))
::
++  json-roundtrip
  |=  jon=json
  ^-  tang
  %+  expect-eq
    !>(`jon)
  !>((de:json:html (json-text:json-lib jon)))
::
++  expect-api-accepted
  |=  [url=@t request=web-request:web]
  ^-  tang
  =/  body  (request-text request)
  =/  req  (api-request url %.y `body `'application/json')
  =/  out  (poke-http req)
  (expect-eq !>(503) !>((response-status -.out)))
::
++  bind-card
  ^-  card:agent:gall
  :*  %pass  /eyre/connect  %arvo  %e
      %connect  `/apps/obelisk  %obelisk-web
  ==
::
++  test-web-init-bind-06
  =/  out  on-init:~(. agent bowl)
  ;:  weld
    (expect-eq !>(~[bind-card]) !>(-.out))
    (expect-eq !>(empty-saved-state:state) on-save:+.out)
  ==
::
++  test-web-load-bind-07
  =/  out
    (on-load:~(. agent bowl) !>(empty-saved-state:state))
  ;:  weld
    (expect-eq !>(~[bind-card]) !>(-.out))
    (expect-eq !>(empty-saved-state:state) on-save:+.out)
  ==
::
++  test-web-load-corrupt-08
  =/  out
    (on-load:~(. agent bowl) !>([%not-an-obelisk-web-state ~]))
  ;:  weld
    (expect-eq !>(~[bind-card]) !>(-.out))
    (expect-eq !>(empty-saved-state:state) on-save:+.out)
  ==
::
++  test-web-page-root-09
  =/  out  (poke-http (request %'GET' '/apps/obelisk'))
  ;:  weld
    (expect-eq !>(200) !>((response-status -.out)))
    %+  expect-eq
      !>(~[['content-type' 'text/html; charset=utf-8']])
    !>((response-headers -.out))
    %-  expect
    !>(?=(^ (find "Obelisk" (trip (response-body -.out)))))
  ==
::
++  test-web-page-trailing-slash-10
  =/  out  (poke-http (request %'GET' '/apps/obelisk/'))
  (expect-eq !>(200) !>((response-status -.out)))
::
++  test-web-javascript-11
  =/  out  (poke-http (request %'GET' '/apps/obelisk/app.js'))
  ;:  weld
    (expect-eq !>(200) !>((response-status -.out)))
    %+  expect-eq
      !>(~[['content-type' 'text/javascript; charset=utf-8']])
    !>((response-headers -.out))
  ==
::
++  test-web-css-12
  =/  out  (poke-http (request %'GET' '/apps/obelisk/app.css'))
  ;:  weld
    (expect-eq !>(200) !>((response-status -.out)))
    %+  expect-eq
      !>(~[['content-type' 'text/css; charset=utf-8']])
    !>((response-headers -.out))
  ==
::
++  test-web-method-not-allowed-13
  =/  out  (poke-http (request %'POST' '/apps/obelisk'))
  ;:  weld
    (expect-eq !>(405) !>((response-status -.out)))
    %+  expect-eq
      !>(~[['content-type' 'text/plain'] ['allow' 'GET']])
    !>((response-headers -.out))
    (expect-eq !>('method not allowed') !>((response-body -.out)))
  ==
::
++  test-web-not-found-14
  =/  out  (poke-http (request %'GET' '/apps/obelisk/nope'))
  ;:  weld
    (expect-eq !>(404) !>((response-status -.out)))
    (expect-eq !>('not found') !>((response-body -.out)))
  ==
::
++  test-web-unknown-mark-delegates-15
  %-  expect-fail
  |.  (on-poke:~(. agent bowl) %noun !>(~))
::
++  test-web-foreign-source-rejected-16
  =/  req  (request %'GET' '/apps/obelisk')
  %-  expect-fail
  |.  (poke-http-with req foreign-bowl)
::
++  test-web-api-unauthenticated-17
  =/  body  (request-text [%run %sys 'SELECT 1;'])
  =/  req
    (api-request '/apps/obelisk/api/run' %.n `body `'application/json')
  =/  out  (poke-http req)
  ;:  weld
    (expect-eq !>(401) !>((response-status -.out)))
    (expect-eq !>('unauthorized') !>((response-error-code -.out)))
    %+  expect-eq
      !>(`'application/json; charset=utf-8')
    !>((get-header:http 'content-type' (response-headers -.out)))
    %+  expect-eq
      !>(`'nosniff')
    !>((get-header:http 'x-content-type-options' (response-headers -.out)))
  ==
::
++  test-web-api-method-18
  =/  out  (poke-http (request %'GET' '/apps/obelisk/api/run'))
  ;:  weld
    (expect-eq !>(405) !>((response-status -.out)))
    %+  expect-eq
      !>(`'POST')
    !>((get-header:http 'allow' (response-headers -.out)))
  ==
::
++  test-web-api-content-type-19
  =/  body  (request-text [%run %sys 'SELECT 1;'])
  =/  req  (api-request '/apps/obelisk/api/run' %.y `body ~)
  =/  out  (poke-http req)
  ;:  weld
    (expect-eq !>(415) !>((response-status -.out)))
    %+  expect-eq
      !>('unsupported-media')
    !>((response-error-code -.out))
  ==
::
++  test-web-api-missing-body-20
  =/  req
    (api-request '/apps/obelisk/api/run' %.y ~ `'application/json')
  =/  out  (poke-http req)
  ;:  weld
    (expect-eq !>(400) !>((response-status -.out)))
    (expect-eq !>('bad-request') !>((response-error-code -.out)))
  ==
::
++  test-web-api-body-limit-21
  =/  body  (request-text [%run %sys 'SELECT 1;'])
  =/  req
    (api-request '/apps/obelisk/api/run' %.y `body `'application/json')
  =.  body.request.req  `[1.048.577 0]
  =/  out  (poke-http req)
  ;:  weld
    (expect-eq !>(413) !>((response-status -.out)))
    %+  expect-eq
      !>('payload-too-large')
    !>((response-error-code -.out))
  ==
::
++  test-web-api-malformed-json-22
  =/  req
    (api-request '/apps/obelisk/api/run' %.y `'{]' `'application/json')
  =/  out  (poke-http req)
  ;:  weld
    (expect-eq !>(400) !>((response-status -.out)))
    (expect-eq !>('bad-request') !>((response-error-code -.out)))
  ==
::
++  test-web-api-route-mismatch-23
  =/  body  (request-text [%parse %sys 'SELECT 1;'])
  =/  req
    (api-request '/apps/obelisk/api/run' %.y `body `'application/json')
  =/  out  (poke-http req)
  ;:  weld
    (expect-eq !>(400) !>((response-status -.out)))
    (expect-eq !>('bad-request') !>((response-error-code -.out)))
  ==
::
++  test-web-api-valid-boundary-24
  =/  body  (request-text [%run %sys hostile-text])
  =/  req
    %:  api-request
      '/apps/obelisk/api/run'
      %.y
      `body
      `'Application/JSON; Charset=UTF-8'
    ==
  =/  out  (poke-http req)
  ;:  weld
    (expect-eq !>(503) !>((response-status -.out)))
    (expect-eq !>('unavailable') !>((response-error-code -.out)))
    %+  expect-eq
      !>(`'no-store')
    !>((get-header:http 'cache-control' (response-headers -.out)))
  ==
::
++  test-json-request-roundtrips-25
  =/  fixtures=(list web-request:web)
    :~  [%run %sys hostile-text]
        [%parse %my-db '']
        [%schema ~]
        [%schema `%other-db]
        [%file-browse ~[%scripts %nested]]
        [%file-load ~[%scripts %query-1]]
        [%file-save ~[%results %result-1] hostile-text %.y]
    ==
  %-  zing
  %+  turn  fixtures
  |=  req=web-request:web
  %+  expect-eq
    !>(`req)
  !>((request-from-text:json-lib (request-text req)))
::
++  test-json-request-rejects-malformed-26
  =/  invalid-types=(unit web-request:web)
    %-  request-from-text:json-lib
    '{"type":"run","defaultDatabase":7,"script":[]}'
  =/  invalid-database=(unit web-request:web)
    %-  request-from-text:json-lib
    '{"type":"run","defaultDatabase":"bad db","script":""}'
  =/  unknown-type=(unit web-request:web)
    (request-from-text:json-lib '{"type":"unknown"}')
  ;:  weld
    (expect-eq !>(*(unit web-request:web)) !>(invalid-types))
    (expect-eq !>(*(unit web-request:web)) !>(invalid-database))
    (expect-eq !>(*(unit web-request:web)) !>(unknown-type))
  ==
::
++  test-json-response-roundtrips-27
  =/  result-set=result-set-dto:web
    :*  ~[[%value '@t']]
        ~[~[[%value '@t' hostile-text]]]
    ==
  =/  results=(list result-dto:web)
    :~  [%action hostile-text]
        [%relation-name hostile-text]
        [%message hostile-text]
        [%vector-count 42]
        [%server-time ~2026.8.1]
        [%security-time ~2026.8.1]
        [%schema-time ~2026.8.1]
        [%data-time ~2026.8.1]
        [%result-set result-set]
        [%relations hostile-text]
        [%select-relation hostile-text]
    ==
  =/  key=key-dto:web  [0 %.y]
  =/  column=column-dto:web  [%id '@ud' 0 `key]
  =/  relation=relation-dto:web
    [%example %public %items %table ~[column]]
  =/  namespace=namespace-dto:web  [%public ~[relation]]
  =/  database=database-dto:web  [%example %.y ~[namespace]]
  =/  schema=schema-dto:web  [%example ~[database]]
  =/  error=web-error:web
    [%unprocessable 422 hostile-text %.n ~[hostile-text]]
  =/  responses=(list web-response:web)
    :~  [%run ~[[0 results]] %.y]
        [%parse ~[hostile-text ''] hostile-text]
        [%schema schema]
        [%file-list ~[[~[%scripts %query-1] %file]]]
        [%file ~[%scripts %query-1] hostile-text]
        [%saved ~[%scripts %query-1]]
        [%error error]
    ==
  =/  checks=tang
    %-  zing
    %+  turn  responses
    |=  response=web-response:web
    =/  jon=json  (response-json:json-lib response)
    =/  tag=@t  `@t`-.response
    ;:  weld
      (json-roundtrip jon)
      %+  expect-eq
        !>(`tag)
      !>((text-field:json-lib 'type' jon))
    ==
  =/  encoded-error=json  (response-json:json-lib [%error error])
  =/  error-object=json  (need (field:json-lib 'error' encoded-error))
  ;:  weld
    checks
    %+  expect-eq
      !>(`hostile-text)
    !>((text-field:json-lib 'message' error-object))
  ==
::
++  test-web-malformed-http-vase-28
  =/  out
    (on-poke:~(. agent bowl) %handle-http-request !>(~))
  ;:  weld
    (expect-eq !>(*(list card:agent:gall)) !>(-.out))
    (expect-eq !>(empty-saved-state:state) on-save:+.out)
  ==
::
++  test-web-api-route-contract-29
  ;:  weld
    %+  expect-api-accepted
      '/apps/obelisk/api/run'
    [%run %sys 'SELECT 1;']
    %+  expect-api-accepted
      '/apps/obelisk/api/parse'
    [%parse %sys 'SELECT 1;']
    %+  expect-api-accepted
      '/apps/obelisk/api/schema'
    [%schema `%sys]
    %+  expect-api-accepted
      '/apps/obelisk/api/files/browse'
    [%file-browse ~[%scripts]]
    %+  expect-api-accepted
      '/apps/obelisk/api/files/load'
    [%file-load ~[%scripts %query-1]]
    %+  expect-api-accepted
      '/apps/obelisk/api/files/save'
    [%file-save ~[%scripts %query-1] 'SELECT 1;' %.n]
  ==
--
