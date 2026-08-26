::  Tests for %obelisk-web shared types and state lifecycle.
::
/-  ast=obelisk-ast, web=obelisk-web
/+  file-lib=obelisk-web-file, json-lib=obelisk-web-json
/+  result-lib=obelisk-web-result
/+  schema-lib=obelisk-web-schema
/+  state=obelisk-web, *test
/=  agent  /app/obelisk-web
/=  backend  /app/obelisk
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
      context=[%none ~]
      phase=%waiting
      watch-wire=/obelisk-web/work/41/2/0/watch
      poke-wire=/obelisk-web/work/41/2/0/poke
      timeout-wire=/obelisk-web/work/41/2/0/timeout
      retries=2
      stage=0
  ==
::
++  dirty-transient-fixture
  ^-  transient-state:web
  :*  binding=%bound
      next-request-id=42
      queue=~[queued-fixture]
      active=`active-fixture
      readiness=~
      file-save=~
      file-delete=~
      result-cache=~
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
    !>(`live-state:web`[%0 ~ [%unbound 0 ~ ~ ~ ~ ~ ~]])
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
  (stage-wire request-id attempt 0 kind)
::
++  stage-wire
  |=  [request-id=@ud attempt=@ud stage=@ud kind=term]
  ^-  wire
  :~  %obelisk-web
      %work
      (scot %ud request-id)
      (scot %ud attempt)
      (scot %ud stage)
      kind
  ==
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
  (work-watch-card-at request-id attempt 0)
::
++  work-watch-card-at
  |=  [request-id=@ud attempt=@ud stage=@ud]
  ^-  card:agent:gall
  :*  %pass
      (stage-wire request-id attempt stage %watch)
      %agent
      [~zod %obelisk]
      %watch
      /server
  ==
::
++  work-timeout-card
  |=  [request-id=@ud attempt=@ud]
  ^-  card:agent:gall
  (work-timeout-card-at request-id attempt 0)
::
++  work-timeout-card-at
  |=  [request-id=@ud attempt=@ud stage=@ud]
  ^-  card:agent:gall
  :*  %pass
      (stage-wire request-id attempt stage %timeout)
      %arvo
      %b
      %wait
      (add ~2026.8.1 work-timeout:state)
  ==
::
++  work-leave-card
  |=  [request-id=@ud attempt=@ud]
  ^-  card:agent:gall
  (work-leave-card-at request-id attempt 0)
::
++  work-leave-card-at
  |=  [request-id=@ud attempt=@ud stage=@ud]
  ^-  card:agent:gall
  :*  %pass
      (stage-wire request-id attempt stage %watch)
      %agent
      [~zod %obelisk]
      %leave
      ~
  ==
::
++  work-poke-card
  |=  [request-id=@ud attempt=@ud action=action:ast]
  ^-  card:agent:gall
  (work-poke-card-at request-id attempt 0 action)
::
++  work-poke-card-at
  |=  [request-id=@ud attempt=@ud stage=@ud action=action:ast]
  ^-  card:agent:gall
  :*  %pass
      (stage-wire request-id attempt stage %poke)
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
++  result-command
  |=  vectors=(list vector:ast)
  ^-  cmd-result:ast
  [%results ~[[%result-set vectors]]]
::
++  numbered-vectors
  |=  count=@ud
  ^-  (list vector:ast)
  (numbered-vectors-from 0 count)
::
++  numbered-vectors-from
  |=  [index=@ud count=@ud]
  ^-  (list vector:ast)
  ?:  =(index count)  ~
  :-  [%vector ~[[%row [%ud index]]]]
  $(index +(index))
::
++  database-command
  |=  databases=(list @tas)
  ^-  cmd-result:ast
  =/  vectors=(list vector:ast)
    %+  turn  databases
    |=  database=@tas
    [%vector ~[[%database [%tas database]]]]
  (result-command vectors)
::
++  schema-detail-commands
  ^-  (list cmd-result:ast)
  =/  namespaces=(list vector:ast)
    :~  [%vector ~[[%namespace [%tas %zeta]]]]
        [%vector ~[[%namespace [%tas %sys]]]]
        [%vector ~[[%namespace [%tas %public]]]]
    ==
  =/  tables=(list vector:ast)
    ~[[%vector ~[[%namespace [%tas %public]] [%name [%tas %widgets]]]]]
  =/  keys=(list vector:ast)
    :~  :*  %vector
            :~  [%namespace [%tas %public]]
                [%name [%tas %widgets]]
                [%key-ordinal [%ud 1]]
                [%key [%tas %id]]
                [%key-ascending [%f 0]]
            ==
        ==
    ==
  =/  columns=(list vector:ast)
    :~  :*  %vector
            :~  [%namespace [%tas %public]]
                [%name [%tas %widgets]]
                [%col-ordinal [%ud 2]]
                [%col-name [%tas %id]]
                [%col-type [%ta %ud]]
            ==
        ==
        :*  %vector
            :~  [%namespace [%tas %public]]
                [%name [%tas %widgets]]
                [%col-ordinal [%ud 1]]
                [%col-name [%tas %label]]
                [%col-type [%ta %t]]
            ==
        ==
    ==
  =/  foreign-keys=(list vector:ast)
    :~  :*  %vector
            :~  [%parent-namespace [%tas %public]]
                [%parent-table [%tas %parents]]
                [%child-namespace [%tas %public]]
                [%child-table [%tas %widgets]]
                [%ordinal [%ud 1]]
                [%parent-column [%tas %id]]
                [%child-column [%tas %id]]
                [%on-delete [%tas %restrict]]
                [%on-update [%tas %cascade]]
            ==
        ==
    ==
  :~  (result-command namespaces)
      (result-command tables)
      (result-command keys)
      (result-command columns)
      (result-command foreign-keys)
  ==
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
++  finish-run-request
  |=  $:  req=inbound-request:eyre
          parsed=(list command:ast)
          response=sign:agent:gall
      ==
  ^-  (quip card:agent:gall agent:gall)
  =/  first  (poke-http req)
  =/  ready
    (signal-agent +.first (readiness-wire 0) watch-ack)
  =/  watched
    (signal-agent +.ready (work-wire 0 0 %watch) watch-ack)
  =/  poked
    (signal-agent +.watched (work-wire 0 0 %poke) poke-ack)
  =/  parsed-out
    %:  signal-agent
      +.poked
      (work-wire 0 0 %watch)
      (parse-fact [%.y parsed])
    ==
  =/  script-watched
    (signal-agent +.parsed-out (stage-wire 0 0 1 %watch) watch-ack)
  =/  script-poked
    (signal-agent +.script-watched (stage-wire 0 0 1 %poke) poke-ack)
  (signal-agent +.script-poked (stage-wire 0 0 1 %watch) response)
::
++  wake-sign
  ^-  sign-arvo
  [%behn %wake ~]
::
++  eyre-bound-sign
  |=  accepted=?
  ^-  sign-arvo
  [%eyre %bound accepted `/apps/obelisk]
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
++  test-web-public-page-allows-eyre-guest-16a
  =/  req  (request %'GET' '/apps/obelisk')
  =.  authenticated.req  %.n
  =/  out  (poke-http-with req foreign-bowl)
  (expect-eq !>(200) !>((response-status -.out)))
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
        :*  %result-save
            7
            2
            %markdown
            ~[%results %result-1 %md]
            %.n
        ==
        [%file-browse ~]
        [%file-browse ~[%scripts %nested]]
        [%file-load ~[%scripts %query-1]]
        [%file-delete ~[%scripts %query-1]]
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
  =/  column=column-dto:web  [%id '@ud' '0' 0 `key]
  =/  foreign-key=foreign-key-dto:web
    [%public %parent 1 %id %parent-id %restrict %cascade]
  =/  relation=relation-dto:web
    [%example %public %items %table ~[column] ~[foreign-key]]
  =/  namespace=namespace-dto:web  [%public ~[relation]]
  =/  database=database-dto:web  [%example %.y ~[namespace]]
  =/  schema=schema-dto:web  [%example ~[database]]
  =/  error=web-error:web
    [%unprocessable 422 hostile-text %.n ~[hostile-text]]
  =/  responses=(list web-response:web)
    :~  [%run 7 ~[[0 results]] %.y]
        [%parse ~[hostile-text ''] hostile-text]
        [%schema schema]
        [%file-list ~[[~[%scripts %query-1] %file]]]
        [%file ~[%scripts %query-1] hostile-text]
        [%saved ~[%scripts %query-1]]
        [%deleted ~[%scripts %query-1]]
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
      (parse-fact [%.y ~])
    ==
  =/  script-watched
    (signal-agent +.fact (stage-wire 0 0 1 %watch) watch-ack)
  =/  script-poked
    (signal-agent +.script-watched (stage-wire 0 0 1 %poke) poke-ack)
  =/  finished
    %:  signal-agent
      +.script-poked
      (stage-wire 0 0 1 %watch)
      (query-fact [%.y ~])
    ==
  =/  stale
    (signal-agent +.finished (work-wire 0 0 %watch) kick-sign)
  ;:  weld
    %+  expect-eq
      !>  :~  (leave-card 0)
              (work-watch-card 0 0)
              (work-timeout-card 0 0)
          ==
    !>(-.ready)
    %+  expect-eq
      !>  ~[(work-poke-card 0 0 [%parse %sys "SELECT 1;"])]
    !>(-.watched)
    (expect-eq !>(*(list card:agent:gall)) !>(-.poked))
    %+  expect-eq
      !>  :~  (work-leave-card 0 0)
              (work-watch-card-at 0 0 1)
              (work-timeout-card-at 0 0 1)
          ==
    !>(-.fact)
    %+  expect-eq
      !>  ~[(work-poke-card-at 0 0 1 [%script %sys %raw "SELECT 1;"])]
    !>(-.script-watched)
    (expect-eq !>((work-leave-card-at 0 0 1)) !>((first-card -.finished)))
    (expect-eq !>(200) !>((response-status (tail-cards -.finished))))
    %+  expect-eq
      !>(~[/http-response/first])
    !>((response-paths (tail-cards -.finished)))
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
  =/  out  (finish-run-request req ~ (query-fact [%.y commands]))
  =/  response-cards  (tail-cards -.out)
  =/  expected=web-response:web
    :*  %run
        0
        :~  :*  0
                :~  [%action 'SELECT']
                    :*  %result-set
                        ~[[%answer %ud]]
                        ~[~[[%answer %ud '42']]]
                    ==
                    [%vector-count 1]
                ==
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
++  test-result-save-rejects-missing-cache-42-a
  =/  save-body
    %-  request-text
    [%result-save 0 0 %csv ~[%results %result-1 %csv] %.n]
  =/  save-request
    %:  api-request
      '/apps/obelisk/api/results/save'
      %.y
      `save-body
      `'application/json'
    ==
  =/  saved  (poke-http save-request)
  ;:  weld
    (expect-eq !>(404) !>((response-status -.saved)))
    (expect-eq !>('not-found') !>((response-error-code -.saved)))
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
  =/  out  (finish-run-request req ~ (query-fact [%.n trace]))
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
  =/  run-out  (finish-run-request run-request ~ (query-fact [%.y ~]))
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
      !>((response-json:json-lib [%run 0 ~ %.n]))
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
::
++  test-schema-construction-49
  =/  response=(unit web-response:web)
    %:  schema-response:schema-lib
      `%missing
      ~[%alpha %sys]
      schema-detail-commands
    ==
  ?~  response  (expect !>(%.n))
  ?>  ?=(%schema -.u.response)
  =/  schema=schema-dto:web  value.u.response
  =/  alpha=database-dto:web  (snag 0 databases.schema)
  =/  system=database-dto:web  (snag 1 databases.schema)
  =/  system-namespace=namespace-dto:web  (snag 0 namespaces.system)
  =/  public=namespace-dto:web  (snag 0 namespaces.alpha)
  =/  sys-namespace=namespace-dto:web  (snag 1 namespaces.alpha)
  =/  widgets=relation-dto:web  (snag 0 relations.public)
  =/  label=column-dto:web  (snag 0 columns.widgets)
  =/  id=column-dto:web  (snag 1 columns.widgets)
  =/  foreign-key=foreign-key-dto:web  (snag 0 foreign-keys.widgets)
  =/  date=column-dto:web  (make-column:schema-lib 1 %date %da)
  =/  expected-key=(unit key-dto:web)  `[1 %.y]
  =/  expected-views=(list @tas)
    :~  %columns
        %data-log
        %foreign-keys
        %namespaces
        %sys-log
        %table-keys
        %tables
    ==
  =/  system-relations=(list @tas)
    %+  turn  relations.system-namespace
    |=  relation=relation-dto:web
    name.relation
  ;:  weld
    (expect-eq !>(%alpha) !>(default-database.schema))
    %+  expect-eq
      !>(%sys)
    !>((default-database:schema-lib `%sys ~[%alpha %sys]))
    %+  expect-eq
      !>(%sys)
    !>((default-database:schema-lib ~ ~[%sys]))
    %+  expect-eq
      !>(~[%alpha %sys])
    !>((turn databases.schema |=(database=database-dto:web name.database)))
    %+  expect-eq
      !>(~[%public %sys %zeta])
    !>((turn namespaces.alpha |=(namespace=namespace-dto:web name.namespace)))
    %+  expect-eq
      !>(~[%label %id])
    !>((turn columns.widgets |=(column=column-dto:web name.column)))
    (expect-eq !>("''") !>((trip bunt.label)))
    (expect-eq !>("0") !>((trip bunt.id)))
    (expect-eq !>("~2000.1.1") !>((trip bunt.date)))
    (expect-eq !>(~) !>(key.label))
    (expect-eq !>(expected-key) !>(key.id))
    %+  expect-eq
      !>  :*  parent-namespace=%public
              parent-table=%parents
              ordinal=1
              parent-column=%id
              child-column=%id
              on-delete=%restrict
              on-update=%cascade
          ==
    !>(foreign-key)
    (expect-eq !>(7) !>((lent relations.sys-namespace)))
    %+  expect-eq
      !>(expected-views)
    !>((turn relations.sys-namespace |=(r=relation-dto:web name.r)))
    (expect-eq !>(%.y) !>(default.alpha))
    (expect-eq !>(%.n) !>(default.system))
    (expect-eq !>(~[%databases]) !>(system-relations))
  ==
::
++  test-schema-malformed-vectors-50
  =/  bad-database=cmd-result:ast
    (result-command ~[[%vector ~[[%database [%ta %alpha]]]]])
  =/  too-short=(list cmd-result:ast)
    (slag 1 schema-detail-commands)
  ;:  weld
    %+  expect-eq
      !>(*(unit (list @tas)))
    !>((database-names:schema-lib ~[bad-database]))
    %+  expect-eq
      !>(*(unit web-response:web))
    !>((schema-response:schema-lib ~ ~[%alpha] too-short))
  ==
::
++  test-schema-query-sequence-51
  =/  expected=tape
    %+  weld  (namespaces-query:schema-lib %alpha)
    %+  weld  (tables-query:schema-lib %alpha)
    %+  weld  (keys-query:schema-lib %alpha)
    %+  weld  (columns-query:schema-lib %alpha)
    (foreign-keys-query:schema-lib %alpha)
  ;:  weld
    %+  expect-eq
      !>("FROM sys.sys.databases SELECT database;")
    !>(databases-query:schema-lib)
    %+  expect-eq
      !>(expected)
    !>((detail-script:schema-lib ~[%sys %alpha]))
    (expect !>(?=(^ (find "foreign-keys" expected))))
  ==
::
++  test-schema-refresh-decisions-52
  =/  ddl=(list command:ast)
    ~[[%create-database %created ~]]
  =/  body  (request-text [%run %sys 'CREATE DATABASE created;'])
  =/  req
    (api-request '/apps/obelisk/api/run' %.y `body `'application/json')
  =/  out  (finish-run-request req ddl (query-fact [%.y ~]))
  =/  response-cards  (tail-cards -.out)
  ;:  weld
    (expect !>((schema-changing:schema-lib ddl)))
    %+  expect-eq
      !>((response-json:json-lib [%run 0 ~ %.y]))
    !>((response-json response-cards))
  ==
::
++  test-schema-coordinator-53
  =/  body  (request-text [%schema `%missing])
  =/  req
    (api-request '/apps/obelisk/api/schema' %.y `body `'application/json')
  =/  first  (poke-http req)
  =/  ready
    (signal-agent +.first (readiness-wire 0) watch-ack)
  =/  watched
    (signal-agent +.ready (work-wire 0 0 %watch) watch-ack)
  =/  databases
    %:  signal-agent
      +.watched
      (work-wire 0 0 %watch)
      (query-fact [%.y ~[(database-command ~[%sys %alpha])]])
    ==
  =/  details-watched
    (signal-agent +.databases (stage-wire 0 0 1 %watch) watch-ack)
  =/  details-poked
    (signal-agent +.details-watched (stage-wire 0 0 1 %poke) poke-ack)
  =/  finished
    %:  signal-agent
      +.details-poked
      (stage-wire 0 0 1 %watch)
      (query-fact [%.y schema-detail-commands])
    ==
  =/  response-cards  (tail-cards -.finished)
  =/  database-action=action:ast
    [%script %sys %vector databases-query:schema-lib]
  =/  detail-action=action:ast
    [%script %sys %vector (detail-script:schema-lib ~[%alpha %sys])]
  =/  response-value=json
    (need (field:json-lib 'value' (response-json response-cards)))
  ;:  weld
    %+  expect-eq
      !>(~[(work-poke-card 0 0 database-action)])
    !>(-.watched)
    %+  expect-eq
      !>  :~  (work-leave-card 0 0)
              (work-watch-card-at 0 0 1)
              (work-timeout-card-at 0 0 1)
          ==
    !>(-.databases)
    %+  expect-eq
      !>(~[(work-poke-card-at 0 0 1 detail-action)])
    !>(-.details-watched)
    (expect-eq !>(200) !>((response-status response-cards)))
    %+  expect-eq
      !>(`'alpha')
    !>((text-field:json-lib 'defaultDatabase' response-value))
  ==
::
++  test-result-conversion-all-variants-54
  =/  vector=vector:ast
    :*  %vector
        :~  [%text [%t hostile-text]]
            [%name [%tas %alpha]]
            [%count [%ud 42]]
            [%flag [%f 0]]
        ==
    ==
  =/  vectors=(list vector:ast)  ~[vector]
  =/  results=(list result:ast)
    :~  [%action hostile-text]
        [%relation-name 'sys.public.items']
        [%message hostile-text]
        [%vector-count 42]
        [%server-time ~2026.8.1]
        [%security-time ~2026.8.1]
        [%schema-time ~2026.8.1]
        [%data-time ~2026.8.1]
        [%result-set vectors]
        [%relations ~]
        [%select-relation *relation:ast]
    ==
  =/  dtos=(list result-dto:web)
    (turn results result-dto:result-lib)
  =/  result-set=result-dto:web  (snag 8 dtos)
  ?>  ?=(%result-set -.result-set)
  =/  table=result-set-dto:web  value.result-set
  =/  expected-text=@t  (crip ~(rt at hostile-text))
  =/  expected-row=(list result-cell-dto:web)
    :~  [%text 't' expected-text]
        [%name 'tas' 'alpha']
        [%count 'ud' '42']
        [%flag 'f' '.y']
    ==
  =/  metadata=(list @t)  (metadata-results:result-lib dtos)
  =/  response=web-response:web
    (run-response:result-lib ~[[%results results]])
  ;:  weld
    %+  expect-eq
      !>  :~  %action
              %relation-name
              %message
              %vector-count
              %server-time
              %security-time
              %schema-time
              %data-time
              %result-set
              %relations
              %select-relation
          ==
    !>((turn dtos |=(dto=result-dto:web -.dto)))
    %+  expect-eq
      !>(~[[%text 't'] [%name 'tas'] [%count 'ud'] [%flag 'f']])
    !>(columns.table)
    %+  expect-eq
      !>(~[expected-row])
    !>(rows.table)
    (expect-eq !>(10) !>((lent metadata)))
    %+  expect-eq
      !>((cat 3 'message: ' hostile-text))
    !>((snag 0 metadata))
    %+  expect-eq
      !>('message: sys.public.items')
    !>((snag 1 metadata))
    (expect-eq !>('vector count: 42') !>((snag 3 metadata)))
    (json-roundtrip (response-json:json-lib response))
  ==
::
++  test-result-export-multiple-sets-55
  =/  first=result-set-dto:web
    :*  ~[[%alpha '@t'] [%count '@ud']]
        ~[~[[%alpha '@t' 'one'] [%count '@ud' '2']]]
    ==
  =/  second=result-set-dto:web
    :*  ~[[%zeta '@t']]
        ~[~[[%zeta '@t' 'last']]]
    ==
  =/  commands=(list command-dto:web)
    :~  [0 ~[[%message hostile-text] [%result-set first]]]
        [1 ~[[%result-set second] [%vector-count 1]]]
    ==
  ;:  weld
    %+  expect-eq
      !>('alpha,count\0aone,2\0a\0azeta\0alast\0a')
    !>((result-export-text:result-lib commands %comma))
    %+  expect-eq
      !>('alpha count\0aone 2\0a\0azeta\0alast\0a')
    !>((result-export-text:result-lib commands %space))
    %+  expect-eq
      !>('alpha\09count\0aone\092\0a\0azeta\0alast\0a')
    !>((result-export-text:result-lib commands %tab))
    %+  expect-eq
      !>(~[first second])
    !>((result-sets:result-lib commands))
  ==
::
++  test-result-format-on-demand-55-a
  =/  columns
    ^-  (lest $%(column:ast qualified-column:ast))
    ~[[%column %value ~.t 0]]
  =/  data=(map @tas @)
    (~(gas by *(map @tas @)) ~[[%value 'safe']])
  =/  row=data-row:ast  [%indexed-row ~ data]
  =/  relation=relation:ast
    :*  %relation
        ~
        ~[columns]
        ~
        %.n
        *(tree [(list @) (map @tas @)])
        ~[[0 row]]
    ==
  =/  command=cmd-result:ast
    [%results ~[[%relations ~[relation]]]]
  =/  csv=@t  (result-export:result-lib %csv command)
  =/  markdown=@t  (result-export:result-lib %markdown command)
  =/  wain=@t  (result-export:result-lib %wain command)
  ;:  weld
    (expect-eq !>('value\0a\'safe\'') !>(csv))
    (expect !>(?=(^ (find "| 'safe' |" (trip markdown)))))
    (expect-eq !>('value\0a\'safe\'') !>(wain))
  ==
::
++  test-result-export-empty-and-metadata-56
  =/  empty-set=result-set-dto:web  [~ ~]
  =/  header-only=result-set-dto:web  [~[[%value 't']] ~]
  =/  metadata=(list command-dto:web)
    ~[[0 ~[[%message hostile-text]]]]
  =/  empty-command=(list command-dto:web)
    ~[[0 ~[[%result-set empty-set]]]]
  =/  line=@t  (cat 3 'message: ' hostile-text)
  =/  expected=@t  (cat 3 line '\0a')
  ;:  weld
    (expect-eq !>('') !>((result-export-text:result-lib ~ %comma)))
    %+  expect-eq
      !>('')
    !>((result-export-text:result-lib empty-command %comma))
    %+  expect-eq
      !>('value\0a')
    !>  %-  result-export-text:result-lib
        [~[[0 ~[[%result-set header-only]]]] %tab]
    (expect-eq !>(expected) !>((metadata-text:result-lib metadata)))
    %+  expect-eq
      !>(expected)
    !>((query-copy-text:result-lib metadata %comma))
    %+  expect-eq
      !>(~[line])
    !>((metadata-lines:result-lib metadata))
  ==
::
++  test-result-copy-includes-metadata-57
  =/  table=result-set-dto:web
    [~[[%value '@t']] ~[~[[%value '@t' 'safe']]]]
  =/  commands=(list command-dto:web)
    ~[[0 ~[[%result-set table] [%message hostile-text]]]]
  =/  expected=@t
    (cat 3 'value\0asafe\0a\0amessage: ' (cat 3 hostile-text '\0a'))
  %+  expect-eq
    !>(expected)
  !>((query-copy-text:result-lib commands %comma))
::
++  test-parse-export-58
  ;:  weld
    %+  expect-eq
      !>('CREATE TABLE items;\0a')
    !>((parse-export-text:result-lib 'CREATE TABLE items;'))
    %+  expect-eq
      !>('CREATE TABLE items;\0a')
    !>((parse-export-text:result-lib 'CREATE TABLE items;\0a'))
    (expect-eq !>('\0a') !>((parse-export-text:result-lib '')))
  ==
::
++  test-result-paging-and-full-export-59
  =/  vectors=(list vector:ast)  (numbered-vectors 800)
  =/  table=result-set-dto:web  (result-set:result-lib vectors)
  =/  commands=(list command-dto:web)
    ~[[0 ~[[%result-set table]]]]
  =/  exported=@t  (result-export-text:result-lib commands %comma)
  ;:  weld
    (expect !>(!(should-page:result-lib 799)))
    (expect !>((should-page:result-lib 800)))
    (expect !>((should-page:result-lib 801)))
    (expect-eq !>(0) !>((page-count:result-lib 0)))
    (expect-eq !>(2) !>((page-count:result-lib 799)))
    (expect-eq !>(2) !>((page-count:result-lib 800)))
    (expect-eq !>(3) !>((page-count:result-lib 1.001)))
    (expect-eq !>(800) !>((lent rows.table)))
    (expect !>(?=(^ (find "\0a799\0a" (trip exported)))))
  ==
::
++  test-large-result-response-paging-59-a
  =/  vectors=(list vector:ast)  (numbered-vectors 800)
  =/  source=(list cmd-result:ast)
    ~[[%results ~[[%result-set vectors]]]]
  =/  commands=(list command-dto:web)
    (command-dtos:result-lib source 0)
  =/  command=command-dto:web  (snag 0 commands)
  =/  result=result-dto:web  (snag 0 results.command)
  ?>  ?=(%result-set -.result)
  =/  table=result-set-dto:web  value.result
  (expect-eq !>(800) !>((lent rows.table)))
::
++  test-file-path-validation-60
  ;:  weld
    (expect !>((valid-browse-path:file-lib ~)))
    (expect !>((valid-browse-path:file-lib ~[%scripts %nested])))
    (expect !>((valid-file-path:file-lib ~[%scripts %nested %query-1])))
    (expect !>((valid-file-path:file-lib ~[%results %results-1])))
    (expect !>(!(valid-file-path:file-lib ~[%scripts])))
    (expect !>(!(valid-file-path:file-lib ~[%other %query-1])))
    (expect !>(!(valid-file-path:file-lib ~[%scripts '.' %query-1])))
    (expect !>(!(valid-file-path:file-lib ~[%scripts '..' %query-1])))
    (expect !>(!(valid-file-path:file-lib ~[%scripts '' %query-1])))
    (expect !>(!(valid-file-path:file-lib ~[%scripts 'bad path'])))
    (expect !>((valid-storage-mark:file-lib %txt)))
    (expect !>((valid-storage-mark:file-lib %csv)))
    (expect !>((valid-storage-mark:file-lib %tab)))
    (expect !>((valid-storage-mark:file-lib %md)))
    (expect !>((valid-storage-mark:file-lib %html)))
    (expect !>((valid-storage-mark:file-lib %json)))
    (expect !>((valid-storage-mark:file-lib %noun)))
    (expect !>(!(valid-storage-mark:file-lib %hoon)))
    %+  expect-eq
      !>(/data/obelisk/scripts/nested/query-1/txt)
    !>((storage-path:file-lib ~[%scripts %nested %query-1]))
    %+  expect-eq
      !>(/data/obelisk/results/results-1/csv)
    !>((storage-path:file-lib ~[%results %results-1 %csv]))
    %+  expect-eq
      !>(/data/obelisk/results/results-2/txt)
    !>((storage-path:file-lib ~[%results %results-2 %txt]))
    %+  expect-eq
      !>(`~[%results %results-1 %csv])
    !>  %-  logical-path:file-lib
        /data/obelisk/results/results-1/csv
    %+  expect-eq
      !>(`~[%scripts %nested %query-1])
    !>  %-  logical-path:file-lib
        /data/obelisk/scripts/nested/query-1/txt
    %+  expect-eq
      !>(/~zod//~2026.8.1/tomb/~zod/obelisk/~2026.8.1/data/obelisk/txt)
    !>  %:  tomb-beam:file-lib
          %:  clay-beam:file-lib
            ~zod  %obelisk  da+~2026.8.1  /data/obelisk/txt
          ==
        ==
  ==
::
++  test-file-recursive-ordering-61
  =/  physical=(list path)
    :~  /data/obelisk/scripts/zeta/txt
        /data/obelisk/scripts/nested/beta/txt
        /data/obelisk/results/result-1/txt
        /data/obelisk/scripts/nested/alpha/txt
        /data/obelisk/scripts/ignored/hoon
    ==
  =/  expected=(list file-entry-dto:web)
    :~  [~[%scripts %nested] %directory]
        [~[%scripts %nested %alpha] %file]
        [~[%scripts %nested %beta] %file]
        [~[%scripts %zeta] %file]
    ==
  %+  expect-eq
    !>(expected)
  !>((entries-from-physical:file-lib ~[%scripts] physical))
::
++  test-file-text-and-conflicts-62
  =/  text-cage-value=cage  (text-cage:file-lib hostile-text)
  =/  trailing=@t  'first\0a\0a'
  =/  trailing-cage=cage  (text-cage:file-lib trailing)
  =/  md-cage=cage  [%md !>(hostile-text)]
  =/  noun-cage=cage
    [%noun !>((storage-wain:file-lib hostile-text))]
  =/  encoded-md=(each cage tang)
    (cage-from-text:file-lib %md hostile-text)
  =/  encoded-noun=(each cage tang)
    (cage-from-text:file-lib %noun hostile-text)
  =/  invalid-json=(each cage tang)
    (cage-from-text:file-lib %json '{]')
  ?>  ?=(%.y -.encoded-md)
  ?>  ?=(%.y -.encoded-noun)
  ;:  weld
    %+  expect-eq
      !>(`hostile-text)
    !>((text-from-cage:file-lib text-cage-value))
    (expect-eq !>(`trailing) !>((text-from-cage:file-lib trailing-cage)))
    (expect-eq !>(`hostile-text) !>((text-from-cage:file-lib md-cage)))
    (expect-eq !>(`hostile-text) !>((text-from-cage:file-lib noun-cage)))
    (expect !>(=(%md p.p.encoded-md)))
    %+  expect-eq
      !>(`hostile-text)
    !>((text-from-cage:file-lib p.encoded-md))
    (expect !>(=(%noun p.p.encoded-noun)))
    %+  expect-eq
      !>(`hostile-text)
    !>((text-from-cage:file-lib p.encoded-noun))
    (expect !>(?=(%.n -.invalid-json)))
    (expect !>((save-conflict:file-lib %.y %.n)))
    (expect !>(!(save-conflict:file-lib %.y %.y)))
    (expect !>(!(save-conflict:file-lib %.n %.n)))
  ==
::
++  test-file-invalid-http-paths-63
  =/  save-body
    (request-text [%file-save ~[%scripts '..' %query] 'x' %.n])
  =/  save-req
    %:  api-request
      '/apps/obelisk/api/files/save'
      %.y
      `save-body
      `'application/json'
    ==
  =/  load-body  (request-text [%file-load ~[%outside %query]])
  =/  load-req
    %:  api-request
      '/apps/obelisk/api/files/load'
      %.y
      `load-body
      `'application/json'
    ==
  =/  delete-body  (request-text [%file-delete ~[%outside %query]])
  =/  delete-req
    %:  api-request
      '/apps/obelisk/api/files/delete'
      %.y
      `delete-body
      `'application/json'
    ==
  =/  save-out  (poke-http save-req)
  =/  load-out  (poke-http load-req)
  =/  delete-out  (poke-http delete-req)
  ;:  weld
    (expect-eq !>(400) !>((response-status -.save-out)))
    (expect-eq !>('bad-request') !>((response-error-code -.save-out)))
    (expect-eq !>(400) !>((response-status -.load-out)))
    (expect-eq !>('bad-request') !>((response-error-code -.load-out)))
    (expect-eq !>(400) !>((response-status -.delete-out)))
    (expect-eq !>('bad-request') !>((response-error-code -.delete-out)))
  ==
::
++  test-file-save-persistence-64
  =/  relative=relative-path:web  ~[%scripts %step-10-persist]
  =/  content=@t  hostile-text
  =/  json-content=@t  '{"value":"safe"}\0a'
  =/  clay-path=path  (storage-path:file-lib relative)
  =/  riot=riot:clay
    `[[%x ud+1 %obelisk] clay-path (text-cage:file-lib content)]
  =/  csv-path=path  /data/obelisk/results/results-1/csv
  =/  csv-cage=cage  [%csv !>((storage-wain:file-lib content))]
  =/  csv-riot=riot:clay  `[[%x ud+1 %obelisk] csv-path csv-cage]
  =/  html-path=path  /data/obelisk/results/results-1/html
  =/  html-cage=cage  [%html !>(content)]
  =/  html-riot=riot:clay  `[[%x ud+1 %obelisk] html-path html-cage]
  =/  md-path=path  /data/obelisk/results/results-1/md
  =/  md-cage=cage  [%md !>(content)]
  =/  md-riot=riot:clay  `[[%x ud+1 %obelisk] md-path md-cage]
  =/  json-path=path  /data/obelisk/results/results-1/json
  =/  json-cage=cage  [%json !>((need (de:json:html json-content)))]
  =/  json-riot=riot:clay  `[[%x ud+1 %obelisk] json-path json-cage]
  =/  tab-path=path  /data/obelisk/results/results-1/tab
  =/  tab-cage=cage  [%tab !>((storage-wain:file-lib content))]
  =/  tab-riot=riot:clay  `[[%x ud+1 %obelisk] tab-path tab-cage]
  ;:  weld
    %+  expect-eq
      !>(/data/obelisk/scripts/step-10-persist/txt)
    !>(clay-path)
    (expect !>((save-verifies:file-lib content riot)))
    (expect !>((save-verifies:file-lib content csv-riot)))
    (expect !>((save-verifies:file-lib content html-riot)))
    (expect !>((save-verifies:file-lib content md-riot)))
    (expect !>((save-verifies:file-lib json-content json-riot)))
    (expect !>((save-verifies:file-lib content tab-riot)))
  ==
::
++  test-file-save-clay-failure-65
  =/  malformed=riot:clay
    `[[%x ud+1 %obelisk] /data/obelisk/results/bad [%noun !>('x')]]
  ;:  weld
    (expect !>(!(save-verifies:file-lib 'x' ~)))
    (expect !>(!(save-verifies:file-lib 'x' malformed)))
  ==
::
++  test-sail-shell-landmarks-and-controls-66
  =/  out  (poke-http (request %'GET' '/apps/obelisk'))
  =/  html=tape  (trip (response-body -.out))
  =/  local=bowl:gall  bowl
  =/  ship=tape  (trip (scot %p our.local))
  ;:  weld
    (expect !>(?=(^ (find "app-header" html))))
    (expect !>(?=(^ (find "/apps/obelisk/favicon.ico" html))))
    (expect !>(?=(^ (find "schema-pane" html))))
    (expect !>(?=(^ (find "query-editor" html))))
    (expect !>(?=(^ (find "output-pane" html))))
    (expect !>(?=(^ (find "Run" html))))
    (expect !>(?=(^ (find "F5" html))))
    (expect !>(?=(^ (find "Parse" html))))
    (expect !>(?=(^ (find "Save script" html))))
    (expect !>(?=(^ (find "Save result" html))))
    (expect !>(?=(^ (find "help-btn" html))))
    (expect !>(?=(^ (find "help-panel" html))))
    (expect !>(?=(^ (find "close-help" html))))
    (expect !>(?=(^ (find "close-icon" html))))
    (expect !>(?=(^ (find "fallback-help-content" html))))
    (expect !>(?=(^ (find "docs-help-content" html))))
    (expect !>(?=(^ (find "docs-help-tree" html))))
    (expect !>(?=(^ (find "explorer-tabs" html))))
    (expect !>(?=(^ (find "explorer-tab-control" html))))
    (expect !>(?=(^ (find "docs-llm-button" html))))
    (expect !>(?=(^ (find "Reference" html))))
    (expect !>(?=(^ (find "Users Guide" html))))
    (expect !>(?=(^ (find "Roadmap" html))))
    (expect !>(?=(^ (find "Copy script" html))))
    (expect !>(?=(^ (find "Copy results" html))))
    (expect !>(?=(^ (find "Default DB" html))))
    (expect !>(?=(^ (find "For Developers" html))))
    (expect !>(?=(~ (find "header-file-menu" html))))
    (expect !>(?=(^ (find "developer-help-links" html))))
    (expect !>(?=(~ (find "dev-menu-toggle" html))))
    (expect !>(?=(^ (find "API/AST" html))))
    (expect !>(?=(^ (find "urQL LLM" html))))
    (expect !>(?=(^ (find "Sample urQL" html))))
    (expect !>(?=(^ (find "Benchmarks" html))))
    (expect !>(?=(^ (find ship html))))
  ==
::
++  test-sail-shell-assets-and-independence-67
  =/  page-out  (poke-http (request %'GET' '/apps/obelisk'))
  =/  css-out  (poke-http (request %'GET' '/apps/obelisk/app.css'))
  =/  html=tape  (trip (response-body -.page-out))
  =/  lower=tape  (cass html)
  =/  style=tape  (trip (response-body -.css-out))
  ;:  weld
    (expect !>(?=(^ (find "/apps/obelisk/app.css" html))))
    (expect !>(?=(^ (find "/apps/obelisk/app.js" html))))
    (expect !>(?=(^ (find "prefers-color-scheme: dark" style))))
    (expect !>(?=(^ (find "max-width: 760px" style))))
    (expect !>(?=(^ (find ".workbench" style))))
    (expect !>(?=(^ (find ".schema-pane" style))))
    (expect !>(?=(^ (find ".output-pane" style))))
    (expect !>(?=(^ (find ".splitter.inactive" style))))
    (expect !>(?=(^ (find ".docs-help-tree" style))))
    (expect !>(?=(^ (find ".close-icon::before" style))))
    (expect !>(?=(^ (find ".docs-help-static" style))))
    (expect !>(?=(^ (find ".docs-tab-close" style))))
    (expect !>(?=(^ (find ".explorer-tab" style))))
    (expect !>(?=(^ (find "height: 2rem;" style))))
    (expect !>(?=(^ (find ".explorer-tab-control .explorer-tab" style))))
    (expect !>(?=(^ (find "padding-block: 0;" style))))
    (expect !>(?=(~ (find ".explorer-tab-control.active" style))))
    (expect !>(?=(^ (find ".docs-tab-control .explorer-tab" style))))
    (expect !>(?=(~ (find ".docs-tab-control.active .explorer-tab" style))))
    (expect !>(?=(^ (find "border-left: 0;" style))))
    (expect !>(?=(^ (find ".editor-tab-control" style))))
    (expect !>(?=(^ (find ".editor-tab-close" style))))
    (expect !>(?=(^ (find ".docs-frame" style))))
    (expect !>(?=(~ (find "hawk" lower))))
    (expect !>(?=(~ (find "htmx" lower))))
    (expect !>(?=(~ (find "jquery" lower))))
  ==
::
++  test-browser-controller-and-pane-state-68
  =/  out  (poke-http (request %'GET' '/apps/obelisk/app.js'))
  =/  script=tape  (trip (response-body -.out))
  ;:  weld
    (expect !>(?=(^ (find "sessionStorage" script))))
    (expect !>(?=(^ (find "aria-expanded" script))))
    (expect !>(?=(^ (find "pointermove" script))))
    (expect !>(?=(^ (find "classList.toggle('inactive'" script))))
    (expect !>(?=(^ (find "schemaOpen" script))))
    (expect !>(?=(^ (find "outputOpen" script))))
    (expect !>(?=(^ (find "outputRatio: 1 / 3" script))))
    (expect !>(?=(^ (find "scriptRatio = 1 - outputRatio" script))))
    (expect !>(?=(^ (find "event.key === 'Escape'" script))))
    (expect !>(?=(^ (find "setBusy" script))))
    (expect !>(?=(^ (find "setHelpOpen" script))))
    (expect !>(?=(^ (find "refreshHelpVariant" script))))
    (expect !>(?=(^ (find "renderDocsHelpTree" script))))
    (expect !>(?=(^ (find "renderDocsHelpNode" script))))
    (expect !>(?=(^ (find "renderDocsTabs" script))))
    (expect !>(?=(^ (find "openDocsTab" script))))
    (expect !>(?=(^ (find "closeDocsTab" script))))
    (expect !>(?=(^ (find "state.docsTabs" script))))
    (expect !>(?=(^ (find "nextDocs" script))))
    (expect !>(?=(^ (find "document.createElement('iframe')" script))))
    (expect !>(?=(^ (find "docsTabLabel" script))))
    (expect !>(?=(^ (find "docsTabTrail" script))))
    (expect !>(?=(^ (find "'User Docs'" script))))
    (expect !>(?=(^ (find "slice(-2).join(' > ')" script))))
    (expect !>(?=(^ (find "'Data Definition Language', 'DDL'" script))))
    (expect !>(?=(^ (find "'Data Manipulation Language', 'DML'" script))))
    (expect !>(?=(^ (find "frame.contentDocument.title" script))))
    (expect !>(?=(^ (find "new MutationObserver" script))))
    (expect !>(?=(^ (find "event.preventDefault()" script))))
    (expect !>(?=(~ (find "title: 'User Docs'" script))))
    (expect !>(?=(^ (find "Data Definition Language" script))))
    (expect !>(?=(^ (find "Data Manipulation Language" script))))
    (expect !>(?=(^ (find "fetch('/docs'" script))))
    (expect !>(?=(^ (find "pathname.startsWith('/docs')" script))))
    (expect !>(?=(^ (find "/docs/d/obelisk/" script))))
    (expect !>(?=(^ (find "docsAvailable" script))))
    (expect !>(?=(^ (find "helpPanel.hidden" script))))
  ==
::
++  test-editor-and-query-interactions-69
  =/  out  (poke-http (request %'GET' '/apps/obelisk/app.js'))
  =/  script=tape  (trip (response-body -.out))
  ;:  weld
    (expect !>(?=(^ (find "nextDraftName" script))))
    (expect !>(?=(^ (find "selectionStart" script))))
    (expect !>(?=(^ (find "execute('run')" script))))
    (expect !>(?=(^ (find "execute('parse')" script))))
    (expect !>(?=(^ (find "event.key === 'F5'" script))))
    (expect !>(?=(^ (find "navigator.clipboard" script))))
    (expect !>(?=(^ (find "document.execCommand('copy')" script))))
    (expect !>(?=(^ (find "function closeTab(id)" script))))
    (expect !>(?=(^ (find "editor-tab-close" script))))
    (expect !>(?=(^ (find "closeTab(tab.id)" script))))
  ==
::
++  test-web-eyre-bind-response-70
  =/  initialized  on-init:~(. agent bowl)
  =/  accepted
    (on-arvo:~(. +.initialized bowl) /eyre/connect (eyre-bound-sign %.y))
  =/  rejected
    (on-arvo:~(. +.initialized bowl) /eyre/connect (eyre-bound-sign %.n))
  ;:  weld
    (expect-eq !>(~) !>(-.accepted))
    (expect-eq !>(~) !>(-.rejected))
    (expect-eq !>(%bound) !>((binding-after-connect:state %.y)))
    (expect-eq !>(%unbound) !>((binding-after-connect:state %.n)))
  ==
::
++  test-web-http-response-watch-71
  =/  accepted
    (on-watch:~(. agent bowl) /http-response/request)
  ;:  weld
    (expect-eq !>(~) !>(-.accepted))
    %-  expect-fail
    |.  (on-watch:~(. agent bowl) /unknown)
  ==
::
++  test-file-ui-contract-72
  =/  page-out  (poke-http (request %'GET' '/apps/obelisk'))
  =/  js-out  (poke-http (request %'GET' '/apps/obelisk/app.js'))
  =/  html=tape  (trip (response-body -.page-out))
  =/  script=tape  (trip (response-body -.js-out))
  ;:  weld
    (expect !>(?=(^ (find "file-dialog" html))))
    (expect !>(?=(^ (find "file-dialog-list" html))))
    (expect !>(?=(^ (find "files-tab" html))))
    (expect !>(?=(^ (find "files-panel" html))))
    (expect !>(?=(^ (find "files-tree" html))))
    (expect !>(?=(^ (find "file-path-input" html))))
    (expect !>(?=(^ (find "files/browse" script))))
    (expect !>(?=(^ (find "files/load" script))))
    (expect !>(?=(^ (find "files/save" script))))
    (expect !>(?=(^ (find "files/delete" script))))
    (expect !>(?=(^ (find "file-context-menu" html))))
    (expect !>(?=(^ (find "file-context-open" html))))
    (expect !>(?=(^ (find "file-context-delete" html))))
    (expect !>(?=(^ (find "openFileContext" script))))
    (expect !>(?=(^ (find "deleteContextFile" script))))
    (expect !>(?=(^ (find "explorer-file-row" script))))
    (expect !>(?=(^ (find "contextmenu" script))))
    (expect !>(?=(^ (find "file-actions" script))))
    (expect !>(?=(^ (find "This cannot be undone" script))))
    (expect !>(?=(^ (find "scriptPathFromInput" script))))
    (expect !>(?=(^ (find "openSelectedFile" script))))
    (expect !>(?=(^ (find "loadFilePath" script))))
    (expect !>(?=(^ (find "refreshFiles" script))))
    (expect !>(?=(^ (find "explorerFileParent" script))))
    (expect !>(?=(^ (find "explorerFileLabel" script))))
    (expect !>(?=(^ (find "savedFileTabName" script))))
    (expect !>(?=(^ (find "uniqueTabName(savedFileTabName(path))" script))))
    (expect !>(?=(^ (find "savedFileTabName(body.path)" script))))
    (expect !>(?=(^ (find "resultStorageMarks" script))))
    (expect !>(?=(^ (find "updateDisplayedResultMark" script))))
    (expect !>(?=(^ (find "activeTabIsResult" script))))
    (expect !>(?=(^ (find "updateExecutionControls" script))))
    (expect !>(?=(^ (find "saveQueryButton.disabled = busy ||" script))))
    (expect !>(?=(^ (find "if (!runButton.disabled) execute('run')" script))))
    (expect !>(?=(^ (find "path: []" script))))
    (expect !>(?=(^ (find "filesCollapsed" script))))
    (expect !>(?=(^ (find "explorerView" script))))
    (expect !>(?=(^ (find "setExplorerView" script))))
    (expect !>(?=(^ (find "error.status === 409" script))))
    (expect !>(?=(^ (find "savedText" script))))
    (expect !>(?=(^ (find "existing.text = text" script))))
    (expect !>(?=(^ (find "existing.savedText = text" script))))
    (expect !>(?=(^ (find "existing ? 'reloaded' : 'opened'" script))))
  ==
::
++  test-schema-ui-contract-73
  =/  page-out  (poke-http (request %'GET' '/apps/obelisk'))
  =/  js-out  (poke-http (request %'GET' '/apps/obelisk/app.js'))
  =/  html=tape  (trip (response-body -.page-out))
  =/  script=tape  (trip (response-body -.js-out))
  ;:  weld
    (expect !>(?=(^ (find "relation-menu" html))))
    (expect !>(?=(^ (find "schemas-tab" html))))
    (expect !>(?=(^ (find "schema-panel" html))))
    (expect !>(?=(^ (find "relation-select" html))))
    (expect !>(?=(^ (find "relation-insert" html))))
    (expect !>(?=(^ (find "relation-create" html))))
    (expect !>(?=(^ (find "refreshSchema" script))))
    (expect !>(?=(^ (find "schemaExpanded" script))))
    (expect !>(?=(^ (find "details.open = state.schemaExpanded" script))))
    (expect !>(?=(^ (find "schemaChanged" script))))
    (expect !>(?=(^ (find "preferNewDatabase" script))))
    (expect !>(?=(^ (find "defaultDatabase: null" script))))
    (expect !>(?=(^ (find "::WITH (FROM..." script))))
    (expect !>(?=(^ (find "::      SELECT...) AS ..." script))))
    (expect !>(?=(^ (find "::JOIN" script))))
    (expect !>(?=(^ (find "::SCALARS" script))))
    (expect !>(?=(^ (find "::WHERE" script))))
    (expect !>(?=(^ (find "'tbl'" script))))
    (expect !>(?=(^ (find "'vw'" script))))
    (expect !>(?=(^ (find "column.bunt" script))))
    (expect !>(?=(^ (find "PRIMARY KEY" script))))
    (expect !>(?=(^ (find "FOREIGN KEY" script))))
    (expect !>(?=(^ (find "foreignKeys" script))))
    (expect !>(?=(^ (find "marker.textContent = 'fk'" script))))
    (expect !>(?=(~ (find "loadForeignKeys" script))))
    (expect !>(?=(^ (find "renderSchemaChildren" script))))
    (expect !>(?=(^ (find "ensureSchemaLoaded" script))))
  ==
::
++  test-output-ui-contract-74
  =/  page-out  (poke-http (request %'GET' '/apps/obelisk'))
  =/  css-out  (poke-http (request %'GET' '/apps/obelisk/app.css'))
  =/  js-out  (poke-http (request %'GET' '/apps/obelisk/app.js'))
  =/  html=tape  (trip (response-body -.page-out))
  =/  style=tape  (trip (response-body -.css-out))
  =/  script=tape  (trip (response-body -.js-out))
  ;:  weld
    (expect !>(?=(^ (find "save-query-btn" html))))
    (expect !>(?=(^ (find "save-output-btn" html))))
    (expect !>(?=(^ (find "Save results" html))))
    (expect !>(?=(^ (find "save-context-menu" html))))
    (expect !>(?=(^ (find "markdown-view-toggle" html))))
    (expect !>(?=(^ (find "markdown-source-btn" html))))
    (expect !>(?=(^ (find "markdown-preview-btn" html))))
    (expect !>(?=(^ (find "html-preview" html))))
    (expect !>(?=(^ (find "sandbox" html))))
    (expect !>(?=(~ (find "save-results-btn" html))))
    (expect !>(?=(^ (find "results-format-select" html))))
    (expect !>(?=(^ (find "value=\"%csv\"" html))))
    (expect !>(?=(^ (find "value=\"%tab\"" html))))
    (expect !>(?=(^ (find "value=\"%spac\"" html))))
    (expect !>(?=(^ (find "value=\"%markdown\"" html))))
    (expect !>(?=(^ (find "value=\"%html\"" html))))
    (expect !>(?=(^ (find "value=\"%tape\"" html))))
    (expect !>(?=(^ (find "value=\"%json\"" html))))
    (expect !>(?=(^ (find "value=\"%wain\"" html))))
    (expect !>(?=(^ (find "value=\"%manx\"" html))))
    (expect !>(?=(^ (find "value=\"%vector\"" html))))
    (expect !>(?=(^ (find "value=\"%raw\"" html))))
    (expect !>(?=(^ (find "result-table-wrap" style))))
    (expect !>(?=(^ (find "white-space: nowrap" style))))
    (expect !>(?=(^ (find "height: 2.3rem" style))))
    (expect !>(?=(^ (find ".editor-tabs .new-tab" style))))
    (expect !>(?=(^ (find ".copy-icon" style))))
    (expect !>(?=(^ (find ".save-icon" style))))
    (expect !>(?=(^ (find ".help-panel" style))))
    (expect !>(?=(^ (find ".markdown-preview" style))))
    (expect !>(?=(^ (find ".html-preview" style))))
    (expect !>(?=(^ (find "showRunOutput" script))))
    (expect !>(?=(^ (find "showParseOutput" script))))
    (expect !>(?=(^ (find "showErrorOutput" script))))
    (expect !>(?=(^ (find "renderCommand" script))))
    (expect !>(?=(^ (find "renderCommandTabs" script))))
    (expect !>(?=(^ (find "safeCommands.length === 1" script))))
    (expect !>(?=(^ (find "command-tab-panel" script))))
    (expect !>(?=(^ (find "outputState.activeCommand = selected" script))))
    (expect !>(?=(~ (find "command.exports" script))))
    (expect !>(?=(^ (find "results/save" script))))
    (expect !>(?=(^ (find "outputState.resultId" script))))
    (expect !>(?=(^ (find "setPointerCapture" script))))
    (expect !>(?=(^ (find "lostpointercapture" script))))
    (expect !>(?=(^ (find "renderResultSet" script))))
    (expect !>(?=(^ (find "outputCopyAvailable" script))))
    (expect !>(?=(^ (find "outputCopyText" script))))
    (expect !>(?=(^ (find ".command-tabs" style))))
    (expect !>(?=(^ (find ".command-tab" style))))
    (expect !>(?=(^ (find "resultPageSize = 500" script))))
    (expect !>(?=(^ (find "resultPagingThreshold = 800" script))))
    (expect !>(?=(^ (find "makePager('top')" script))))
    (expect !>(?=(^ (find "makePager('bottom')" script))))
    (expect !>(?=(^ (find "pagers.forEach" script))))
    (expect !>(?=(^ (find "runCopyText" script))))
    (expect !>(?=(^ (find "runExportText" script))))
    (expect !>(?=(^ (find "security-time:" script))))
    (expect !>(?=(^ (find "showSaveResultsDialog" script))))
    (expect !>(?=(^ (find "'click', showSaveResultsDialog" script))))
    (expect !>(?=(^ (find "openSaveContext" script))))
    (expect !>(?=(^ (find "directSaveAvailable" script))))
    (expect !>(?=(^ (find "event.clientX" script))))
    (expect !>(?=(^ (find "window.innerWidth" script))))
    (expect !>(?=(^ (find "outputState.path" script))))
    (expect !>(?=(^ (find "previewResultMark" script))))
    (expect !>(?=(^ (find "setResultView" script))))
    (expect !>(?=(^ (find "renderMarkdown" script))))
    (expect !>(?=(^ (find "safeMarkdownHref" script))))
    (expect !>(?=(^ (find "htmlPreview.srcdoc" script))))
    (expect !>(?=(^ (find "resultFormatMarks" script))))
    (expect !>(?=(^ (find "path[path.length - 1] === mark" script))))
    (expect !>(?=(^ (find "nextResultName" script))))
    (expect !>(?=(^ (find "path: ['results']" script))))
    (expect !>(?=(^ (find "error.status === 409" script))))
  ==
::
++  test-packaging-lifecycle-75
  =/  initialized  on-init:~(. agent bowl)
  =/  loaded
    (on-load:~(. agent bowl) !>(empty-saved-state:state))
  ;:  weld
    (expect-eq !>(~[bind-card]) !>(-.initialized))
    (expect-eq !>(~[bind-card]) !>(-.loaded))
    (expect-eq !>(empty-saved-state:state) on-save:+.initialized)
    (expect-eq !>(empty-saved-state:state) on-save:+.loaded)
  ==
::
++  test-live-backend-reply-cages-76
  =/  query-action=action:ast
    [%script %sys %vector "FROM sys.sys.databases SELECT database;"]
  =/  query-out
    %-  on-poke:~(. backend bowl)
    [%obelisk-action !>(query-action)]
  =/  query-cards  -.query-out
  ?>  ?=(^ query-cards)
  =/  query-card  i.query-cards
  ?>  ?=([%give %fact *] query-card)
  =/  query-cage  cage.p.query-card
  =/  query-sign=sign:agent:gall  [%fact query-cage]
  =/  run-body  (request-text [%run %sys ''])
  =/  run-request
    (api-request '/apps/obelisk/api/run' %.y `run-body `'application/json')
  =/  web-query-out  (finish-run-request run-request ~ query-sign)
  =/  parse-action=action:ast
    [%parse %sys "FROM sys.sys.databases SELECT database;"]
  =/  parse-out
    %-  on-poke:~(. backend bowl)
    [%obelisk-action !>(parse-action)]
  =/  parse-cards  -.parse-out
  ?>  ?=(^ parse-cards)
  =/  parse-card  i.parse-cards
  ?>  ?=([%give %fact *] parse-card)
  =/  parse-cage  cage.p.parse-card
  =/  parse-sign=sign:agent:gall  [%fact parse-cage]
  =/  parse-body
    (request-text [%parse %sys 'FROM sys.sys.databases SELECT database;'])
  =/  parse-request
    %:  api-request
      '/apps/obelisk/api/parse'
      %.y
      `parse-body
      `'application/json'
    ==
  =/  web-parse-out  (finish-request parse-request parse-sign)
  ;:  weld
    (expect-eq !>(422) !>((response-status (tail-cards -.web-query-out))))
    (expect-eq !>(200) !>((response-status (tail-cards -.web-parse-out))))
  ==
--
