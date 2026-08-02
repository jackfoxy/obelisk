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
      watch-wire=/obelisk-web/work/41/2/watch
      poke-wire=/obelisk-web/work/41/2/poke
      timeout-wire=/obelisk-web/work/41/2/timeout
      retries=2
  ==
::
++  dirty-transient-fixture
  ^-  transient-state:web
  :*  binding=%bound
      next-request-id=42
      queue=~[queued-fixture]
      active=`active-fixture
      readiness=~
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
    !>(`live-state:web`[%0 ~ [%unbound 0 ~ ~ ~]])
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
    now  ~2026.8.1
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
  (poke-http-id-on agent 'request' req)
::
++  poke-http-on
  |=  [ag=agent:gall req=inbound-request:eyre]
  ^-  (quip card:agent:gall agent:gall)
  (poke-http-id-on ag 'request' req)
::
++  poke-http-id-on
  |=  [ag=agent:gall eyre-id=@ta req=inbound-request:eyre]
  ^-  (quip card:agent:gall agent:gall)
  %-  on-poke:~(. ag bowl)
  [%handle-http-request !>([eyre-id req])]
::
++  poke-http-with
  |=  [req=inbound-request:eyre =bowl:gall]
  ^-  (quip card:agent:gall agent:gall)
  %-  on-poke:~(. agent bowl)
  [%handle-http-request !>(['request' req])]
::
++  signal-agent
  |=  [ag=agent:gall =wire =sign:agent:gall]
  ^-  (quip card:agent:gall agent:gall)
  (on-agent:~(. ag bowl) wire sign)
::
++  wake-agent
  |=  [ag=agent:gall =wire]
  ^-  (quip card:agent:gall agent:gall)
  (on-arvo:~(. ag bowl) wire wake-sign)
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
++  response-paths
  |=  cards=(list card:agent:gall)
  ^-  (list path)
  ?>  ?=(^ cards)
  =/  card  i.cards
  ?>  ?=(%give -.card)
  =/  gift  p.card
  ?>  ?=(%fact -.gift)
  paths.gift
::
++  first-card
  |=  cards=(list card:agent:gall)
  ^-  card:agent:gall
  ?>  ?=(^ cards)
  i.cards
::
++  tail-cards
  |=  cards=(list card:agent:gall)
  ^-  (list card:agent:gall)
  ?>  ?=(^ cards)
  t.cards
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
  ?:  ?|  =(%run -.request)
          =(%parse -.request)
          =(%schema -.request)
      ==
    %+  expect-eq
      !>(~[(watch-card 0)])
    !>(-.out)
  (expect-eq !>(503) !>((response-status -.out)))
::
++  readiness-wire
  |=  request-id=@ud
  ^-  wire
  /obelisk-web/readiness/(scot %ud request-id)
::
++  work-wire
  |=  [request-id=@ud attempt=@ud kind=term]
  ^-  wire
  [%obelisk-web %work (scot %ud request-id) (scot %ud attempt) kind ~]
::
++  watch-card
  |=  request-id=@ud
  ^-  card:agent:gall
  :*  %pass
      (readiness-wire request-id)
      %agent
      [~zod %obelisk]
      %watch
      /server
  ==
::
++  leave-card
  |=  request-id=@ud
  ^-  card:agent:gall
  :*  %pass
      (readiness-wire request-id)
      %agent
      [~zod %obelisk]
      %leave
      ~
  ==
::
++  retry-card
  |=  request-id=@ud
  ^-  card:agent:gall
  :*  %pass
      (readiness-wire request-id)
      %arvo
      %b
      %wait
      (add ~2026.8.1 readiness-delay:state)
  ==
::
++  work-watch-card
  |=  [request-id=@ud attempt=@ud]
  ^-  card:agent:gall
  :*  %pass
      (work-wire request-id attempt %watch)
      %agent
      [~zod %obelisk]
      %watch
      /server
  ==
::
++  work-timeout-card
  |=  [request-id=@ud attempt=@ud]
  ^-  card:agent:gall
  :*  %pass
      (work-wire request-id attempt %timeout)
      %arvo
      %b
      %wait
      (add ~2026.8.1 work-timeout:state)
  ==
::
++  work-leave-card
  |=  [request-id=@ud attempt=@ud]
  ^-  card:agent:gall
  :*  %pass
      (work-wire request-id attempt %watch)
      %agent
      [~zod %obelisk]
      %leave
      ~
  ==
::
++  work-poke-card
  |=  [request-id=@ud attempt=@ud action=action:ast]
  ^-  card:agent:gall
  :*  %pass
      (work-wire request-id attempt %poke)
      %agent
      [~zod %obelisk]
      %poke
      %obelisk-action
      !>(action)
  ==
::
++  watch-nack
  ^-  sign:agent:gall
  [%watch-ack `~[leaf+"Obelisk unavailable"]]
::
++  watch-ack
  ^-  sign:agent:gall
  [%watch-ack ~]
::
++  poke-nack
  ^-  sign:agent:gall
  [%poke-ack `~[leaf+"Obelisk poke failed"]]
::
++  poke-ack
  ^-  sign:agent:gall
  [%poke-ack ~]
::
++  query-fact
  |=  reply=(each (list cmd-result:ast) tang)
  ^-  sign:agent:gall
  [%fact %noun !>(reply)]
::
++  parse-fact
  |=  reply=(each (list command:ast) tang)
  ^-  sign:agent:gall
  [%fact %noun !>(reply)]
::
++  malformed-fact
  ^-  sign:agent:gall
  [%fact %json !>(~)]
::
++  kick-sign
  ^-  sign:agent:gall
  [%kick ~]
::
++  finish-request
  |=  [req=inbound-request:eyre response=sign:agent:gall]
  ^-  (quip card:agent:gall agent:gall)
  =/  first  (poke-http req)
  =/  ready
    (signal-agent +.first (readiness-wire 0) watch-ack)
  =/  watched
    (signal-agent +.ready (work-wire 0 0 %watch) watch-ack)
  =/  poked
    (signal-agent +.watched (work-wire 0 0 %poke) poke-ack)
  (signal-agent +.poked (work-wire 0 0 %watch) response)
::
++  wake-sign
  ^-  sign-arvo
  [%behn %wake ~]
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
  =/  wire  (readiness-wire 0)
  =/  ready  (signal-agent +.out wire watch-ack)
  ;:  weld
    (expect-eq !>(~[(watch-card 0)]) !>(-.out))
    %+  expect-eq
      !>  :~  (leave-card 0)
              (work-watch-card 0 0)
              (work-timeout-card 0 0)
          ==
    !>(-.ready)
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
::
++  test-readiness-unavailable-30
  =/  body  (request-text [%run %sys 'SELECT 1;'])
  =/  req
    (api-request '/apps/obelisk/api/run' %.y `body `'application/json')
  =/  wire  (readiness-wire 0)
  =/  first  (poke-http req)
  =/  nacked  (signal-agent +.first wire watch-nack)
  =/  blocked  (poke-http-on +.nacked req)
  ;:  weld
    (expect-eq !>(~[(watch-card 0)]) !>(-.first))
    (expect-eq !>(~[(retry-card 0)]) !>(-.nacked))
    (expect-eq !>(*(list card:agent:gall)) !>(-.blocked))
  ==
::
++  test-readiness-delayed-ready-31
  =/  body  (request-text [%parse %sys 'SELECT 1;'])
  =/  req
    (api-request '/apps/obelisk/api/parse' %.y `body `'application/json')
  =/  wire  (readiness-wire 0)
  =/  first  (poke-http req)
  =/  nacked  (signal-agent +.first wire watch-nack)
  =/  woke  (wake-agent +.nacked wire)
  =/  ready  (signal-agent +.woke wire watch-ack)
  =/  next  (poke-http-on +.ready req)
  ;:  weld
    (expect-eq !>(~[(retry-card 0)]) !>(-.nacked))
    (expect-eq !>(~[(watch-card 0)]) !>(-.woke))
    %+  expect-eq
      !>  :~  (leave-card 0)
              (work-watch-card 0 1)
              (work-timeout-card 0 1)
          ==
    !>(-.ready)
    (expect-eq !>(*(list card:agent:gall)) !>(-.next))
  ==
::
++  test-readiness-retry-exhausted-32
  =/  body  (request-text [%schema ~])
  =/  req
    (api-request '/apps/obelisk/api/schema' %.y `body `'application/json')
  =/  wire  (readiness-wire 0)
  =/  first  (poke-http req)
  =/  nack-one  (signal-agent +.first wire watch-nack)
  =/  wake-one  (wake-agent +.nack-one wire)
  =/  nack-two  (signal-agent +.wake-one wire watch-nack)
  =/  wake-two  (wake-agent +.nack-two wire)
  =/  nack-three  (signal-agent +.wake-two wire watch-nack)
  =/  next  (poke-http-on +.nack-three req)
  ;:  weld
    (expect-eq !>(~[(retry-card 0)]) !>(-.nack-one))
    (expect-eq !>(~[(watch-card 0)]) !>(-.wake-one))
    (expect-eq !>(~[(retry-card 0)]) !>(-.nack-two))
    (expect-eq !>(~[(watch-card 0)]) !>(-.wake-two))
    (expect-eq !>(503) !>((response-status -.nack-three)))
    (expect-eq !>('unavailable') !>((response-error-code -.nack-three)))
    %+  expect-eq
      !>(`'1')
    !>((get-header:http 'retry-after' (response-headers -.nack-three)))
    (expect-eq !>(~[(watch-card 1)]) !>(-.next))
  ==
::
++  test-readiness-successful-ready-33
  =/  body  (request-text [%run %sys 'SELECT 1;'])
  =/  req
    (api-request '/apps/obelisk/api/run' %.y `body `'application/json')
  =/  wire  (readiness-wire 0)
  =/  first  (poke-http req)
  =/  ready  (signal-agent +.first wire watch-ack)
  =/  next  (poke-http-on +.ready req)
  ;:  weld
    (expect-eq !>(~[(watch-card 0)]) !>(-.first))
    %+  expect-eq
      !>  :~  (leave-card 0)
              (work-watch-card 0 0)
              (work-timeout-card 0 0)
          ==
    !>(-.ready)
    (expect-eq !>(*(list card:agent:gall)) !>(-.next))
  ==
::
++  test-readiness-poke-failure-34
  =/  sign=sign:agent:gall  poke-nack
  ?>  ?=(%poke-ack -.sign)
  =/  decision=readiness-decision:web
    (readiness-step:state ?~(p.sign %.y %.n) 0)
  ;:  weld
    (expect-eq !>(`readiness-decision:web`[%retry 1]) !>(decision))
    %+  expect-eq
      !>(`readiness-decision:web`[%exhausted ~])
    !>((readiness-step:state %.n 2))
  ==
::
++  test-coordinator-watch-before-poke-35
  =/  body  (request-text [%run %sys 'SELECT 1;'])
  =/  req
    (api-request '/apps/obelisk/api/run' %.y `body `'application/json')
  =/  first  (poke-http-id-on agent 'first' req)
  =/  ready
    (signal-agent +.first (readiness-wire 0) watch-ack)
  =/  watched
    (signal-agent +.ready (work-wire 0 0 %watch) watch-ack)
  =/  poked
    (signal-agent +.watched (work-wire 0 0 %poke) poke-ack)
  =/  fact
    %:  signal-agent
      +.poked
      (work-wire 0 0 %watch)
      (query-fact [%.y ~])
    ==
  =/  stale
    (signal-agent +.fact (work-wire 0 0 %watch) kick-sign)
  ;:  weld
    %+  expect-eq
      !>  :~  (leave-card 0)
              (work-watch-card 0 0)
              (work-timeout-card 0 0)
          ==
    !>(-.ready)
    %+  expect-eq
      !>  ~[(work-poke-card 0 0 [%script %sys %vector "SELECT 1;"])]
    !>(-.watched)
    (expect-eq !>(*(list card:agent:gall)) !>(-.poked))
    (expect-eq !>((work-leave-card 0 0)) !>((first-card -.fact)))
    (expect-eq !>(200) !>((response-status (tail-cards -.fact))))
    %+  expect-eq
      !>(~[/http-response/first])
    !>((response-paths (tail-cards -.fact)))
    (expect-eq !>(*(list card:agent:gall)) !>(-.stale))
  ==
::
++  test-coordinator-overlap-isolated-36
  =/  body  (request-text [%parse %sys 'SELECT 1;'])
  =/  req
    (api-request '/apps/obelisk/api/parse' %.y `body `'application/json')
  =/  first  (poke-http-id-on agent 'first' req)
  =/  second  (poke-http-id-on +.first 'second' req)
  =/  ready-zero
    (signal-agent +.second (readiness-wire 0) watch-ack)
  =/  watched-zero
    (signal-agent +.ready-zero (work-wire 0 0 %watch) watch-ack)
  =/  poked-zero
    (signal-agent +.watched-zero (work-wire 0 0 %poke) poke-ack)
  =/  fact-zero
    %:  signal-agent
      +.poked-zero
      (work-wire 0 0 %watch)
      (parse-fact [%.y ~])
    ==
  =/  stale-zero
    (signal-agent +.fact-zero (work-wire 0 0 %watch) kick-sign)
  =/  ready-one
    (signal-agent +.stale-zero (readiness-wire 1) watch-ack)
  =/  watched-one
    (signal-agent +.ready-one (work-wire 1 0 %watch) watch-ack)
  =/  poked-one
    (signal-agent +.watched-one (work-wire 1 0 %poke) poke-ack)
  =/  fact-one
    %:  signal-agent
      +.poked-one
      (work-wire 1 0 %watch)
      (parse-fact [%.y ~])
    ==
  ;:  weld
    (expect-eq !>(*(list card:agent:gall)) !>(-.second))
    %+  expect-eq
      !>(~[/http-response/first])
    !>((response-paths (tail-cards -.fact-zero)))
    %+  expect-eq
      !>((watch-card 1))
    !>((snag 4 -.fact-zero))
    (expect-eq !>(*(list card:agent:gall)) !>(-.stale-zero))
    %+  expect-eq
      !>(~[/http-response/second])
    !>((response-paths (tail-cards -.fact-one)))
  ==
::
++  test-coordinator-timeout-once-37
  =/  body  (request-text [%run %sys 'SELECT 1;'])
  =/  req
    (api-request '/apps/obelisk/api/run' %.y `body `'application/json')
  =/  first  (poke-http req)
  =/  ready
    (signal-agent +.first (readiness-wire 0) watch-ack)
  =/  timed-out
    (wake-agent +.ready (work-wire 0 0 %timeout))
  =/  stale
    %:  signal-agent
      +.timed-out
      (work-wire 0 0 %watch)
      (query-fact [%.y ~])
    ==
  ;:  weld
    (expect-eq !>((work-leave-card 0 0)) !>((first-card -.timed-out)))
    (expect-eq !>(504) !>((response-status (tail-cards -.timed-out))))
    %+  expect-eq
      !>('timeout')
    !>((response-error-code (tail-cards -.timed-out)))
    (expect-eq !>(*(list card:agent:gall)) !>(-.stale))
  ==
::
++  test-coordinator-malformed-fact-once-38
  =/  body  (request-text [%parse %sys 'SELECT 1;'])
  =/  req
    (api-request '/apps/obelisk/api/parse' %.y `body `'application/json')
  =/  first  (poke-http req)
  =/  ready
    (signal-agent +.first (readiness-wire 0) watch-ack)
  =/  watched
    (signal-agent +.ready (work-wire 0 0 %watch) watch-ack)
  =/  malformed
    (signal-agent +.watched (work-wire 0 0 %watch) malformed-fact)
  =/  stale
    (signal-agent +.malformed (work-wire 0 0 %watch) kick-sign)
  ;:  weld
    (expect-eq !>(500) !>((response-status (tail-cards -.malformed))))
    %+  expect-eq
      !>('internal')
    !>((response-error-code (tail-cards -.malformed)))
    (expect-eq !>(*(list card:agent:gall)) !>(-.stale))
  ==
::
++  test-coordinator-lost-subscription-once-39
  =/  body  (request-text [%run %sys 'SELECT 1;'])
  =/  req
    (api-request '/apps/obelisk/api/run' %.y `body `'application/json')
  =/  first  (poke-http req)
  =/  ready
    (signal-agent +.first (readiness-wire 0) watch-ack)
  =/  kicked
    (signal-agent +.ready (work-wire 0 0 %watch) kick-sign)
  =/  stale
    (signal-agent +.kicked (work-wire 0 0 %watch) kick-sign)
  ;:  weld
    (expect-eq !>(503) !>((response-status -.kicked)))
    %+  expect-eq
      !>('unavailable')
    !>((response-error-code -.kicked))
    (expect-eq !>(*(list card:agent:gall)) !>(-.stale))
  ==
::
++  test-coordinator-agent-failure-retries-40
  =/  body  (request-text [%run %sys 'SELECT 1;'])
  =/  req
    (api-request '/apps/obelisk/api/run' %.y `body `'application/json')
  =/  first  (poke-http req)
  =/  ready-zero
    (signal-agent +.first (readiness-wire 0) watch-ack)
  =/  watched-zero
    (signal-agent +.ready-zero (work-wire 0 0 %watch) watch-ack)
  =/  failed
    (signal-agent +.watched-zero (work-wire 0 0 %poke) poke-nack)
  =/  woke  (wake-agent +.failed (readiness-wire 0))
  =/  ready-one
    (signal-agent +.woke (readiness-wire 0) watch-ack)
  =/  watched-one
    (signal-agent +.ready-one (work-wire 0 1 %watch) watch-ack)
  =/  failed-one
    (signal-agent +.watched-one (work-wire 0 1 %poke) poke-nack)
  =/  woke-two  (wake-agent +.failed-one (readiness-wire 0))
  =/  ready-two
    (signal-agent +.woke-two (readiness-wire 0) watch-ack)
  =/  watched-two
    (signal-agent +.ready-two (work-wire 0 2 %watch) watch-ack)
  =/  failed-two
    (signal-agent +.watched-two (work-wire 0 2 %poke) poke-nack)
  =/  stale
    (signal-agent +.failed-two (work-wire 0 2 %watch) kick-sign)
  ;:  weld
    %+  expect-eq
      !>  :~  (work-leave-card 0 0)
              (retry-card 0)
          ==
    !>(-.failed)
    (expect-eq !>(~[(watch-card 0)]) !>(-.woke))
    %+  expect-eq
      !>  :~  (leave-card 0)
              (work-watch-card 0 1)
              (work-timeout-card 0 1)
          ==
    !>(-.ready-one)
    %+  expect-eq
      !>  :~  (work-leave-card 0 1)
              (retry-card 0)
          ==
    !>(-.failed-one)
    %+  expect-eq
      !>  :~  (leave-card 0)
              (work-watch-card 0 2)
              (work-timeout-card 0 2)
          ==
    !>(-.ready-two)
    (expect-eq !>((work-leave-card 0 2)) !>((first-card -.failed-two)))
    (expect-eq !>(503) !>((response-status (tail-cards -.failed-two))))
    %+  expect-eq
      !>('unavailable')
    !>((response-error-code (tail-cards -.failed-two)))
    (expect-eq !>(*(list card:agent:gall)) !>(-.stale))
  ==
::
++  test-coordinator-queue-bound-41
  =/  body  (request-text [%parse %sys 'SELECT 1;'])
  =/  req
    (api-request '/apps/obelisk/api/parse' %.y `body `'application/json')
  =/  first  (poke-http-id-on agent 'active' req)
  =/  ag=agent:gall  +.first
  =/  index=@ud  0
  |-
  ?:  =(index max-queued-requests:state)
    =/  overflow  (poke-http-id-on ag 'overflow' req)
    ;:  weld
      (expect-eq !>(429) !>((response-status -.overflow)))
      %+  expect-eq
        !>('queue-full')
      !>((response-error-code -.overflow))
    ==
  =/  queued
    (poke-http-id-on ag (scot %ud index) req)
  ?>  ?=(~ -.queued)
  $(ag +.queued, index +(index))
::
++  test-run-typed-success-42
  =/  commands=(list cmd-result:ast)
    :~  :-  %results
        :~  [%action 'SELECT']
            [%result-set ~[[%vector ~[[%answer [%ud 42]]]]]]
            [%vector-count 1]
        ==
    ==
  =/  body  (request-text [%run %sys 'SELECT 42;'])
  =/  req
    (api-request '/apps/obelisk/api/run' %.y `body `'application/json')
  =/  out  (finish-request req (query-fact [%.y commands]))
  =/  response-cards  (tail-cards -.out)
  =/  expected=web-response:web
    :*  %run
        :~  :-  0
            :~  [%action 'SELECT']
                :*  %result-set
                    ~[[%answer %ud]]
                    ~[~[[%answer %ud '42']]]
                ==
                [%vector-count 1]
            ==
        ==
        %.n
    ==
  ;:  weld
    (expect-eq !>(200) !>((response-status response-cards)))
    %+  expect-eq
      !>((response-json:json-lib expected))
    !>((response-json response-cards))
  ==
::
++  test-parse-typed-success-43
  =/  commands=(list command:ast)
    ~[[%create-database %db1 ~]]
  =/  body  (request-text [%parse %sys 'CREATE DATABASE db1;'])
  =/  req
    (api-request '/apps/obelisk/api/parse' %.y `body `'application/json')
  =/  out  (finish-request req (parse-fact [%.y commands]))
  =/  response-cards  (tail-cards -.out)
  =/  expected=web-response:web
    :*  %parse
        (turn commands |=(command=command:ast (crip (text !>(command)))))
        (crip (text !>(commands)))
    ==
  ;:  weld
    (expect-eq !>(200) !>((response-status response-cards)))
    %+  expect-eq
      !>((response-json:json-lib expected))
    !>((response-json response-cards))
  ==
::
++  test-parse-failure-44
  =/  trace=tang  ~[leaf+"parse failed at token"]
  =/  body  (request-text [%parse %sys 'NOT URQL'])
  =/  req
    (api-request '/apps/obelisk/api/parse' %.y `body `'application/json')
  =/  out  (finish-request req (parse-fact [%.n trace]))
  =/  response-cards  (tail-cards -.out)
  =/  message-match=(unit @ud)
    (find "parse failed at token" (trip (response-body response-cards)))
  ;:  weld
    (expect-eq !>(422) !>((response-status response-cards)))
    %+  expect-eq
      !>('unprocessable')
    !>((response-error-code response-cards))
    (expect !>(?=(^ message-match)))
  ==
::
++  test-run-execution-failure-45
  =/  trace=tang  ~[leaf+"execution failed safely"]
  =/  body  (request-text [%run %sys 'SELECT missing;'])
  =/  req
    (api-request '/apps/obelisk/api/run' %.y `body `'application/json')
  =/  out  (finish-request req (query-fact [%.n trace]))
  =/  response-cards  (tail-cards -.out)
  =/  message-match=(unit @ud)
    (find "execution failed safely" (trip (response-body response-cards)))
  ;:  weld
    (expect-eq !>(422) !>((response-status response-cards)))
    %+  expect-eq
      !>('unprocessable')
    !>((response-error-code response-cards))
    (expect !>(?=(^ message-match)))
  ==
::
++  test-run-and-parse-empty-script-46
  =/  run-body  (request-text [%run %sys ''])
  =/  run-request
    %:  api-request
      '/apps/obelisk/api/run'
      %.y
      `run-body
      `'application/json'
    ==
  =/  run-out  (finish-request run-request (query-fact [%.y ~]))
  =/  parse-body  (request-text [%parse %sys ''])
  =/  parse-request
    %:  api-request
      '/apps/obelisk/api/parse'
      %.y
      `parse-body
      `'application/json'
    ==
  =/  parse-out  (finish-request parse-request (parse-fact [%.y ~]))
  =/  empty-commands  *(list command:ast)
  =/  expected-parse=json
    %-  response-json:json-lib
    [%parse ~ (crip (text !>(empty-commands)))]
  ;:  weld
    %+  expect-eq
      !>((response-json:json-lib [%run ~ %.n]))
    !>((response-json (tail-cards -.run-out)))
    %+  expect-eq
      !>(expected-parse)
    !>((response-json (tail-cards -.parse-out)))
  ==
::
++  test-parse-rejects-query-reply-47
  =/  query-commands=(list cmd-result:ast)  ~[[%results ~]]
  =/  body  (request-text [%parse %sys 'SELECT 1;'])
  =/  req
    (api-request '/apps/obelisk/api/parse' %.y `body `'application/json')
  =/  out
    (finish-request req (query-fact [%.y query-commands]))
  =/  response-cards  (tail-cards -.out)
  ;:  weld
    (expect-eq !>(500) !>((response-status response-cards)))
    %+  expect-eq
      !>('internal')
    !>((response-error-code response-cards))
  ==
::
++  test-parse-action-shape-48
  =/  body  (request-text [%parse %my-db 'SELECT 1;'])
  =/  req
    (api-request '/apps/obelisk/api/parse' %.y `body `'application/json')
  =/  first  (poke-http req)
  =/  ready
    (signal-agent +.first (readiness-wire 0) watch-ack)
  =/  watched
    (signal-agent +.ready (work-wire 0 0 %watch) watch-ack)
  %+  expect-eq
    !>  ~[(work-poke-card 0 0 [%parse %my-db "SELECT 1;"])]
  !>(-.watched)
--
