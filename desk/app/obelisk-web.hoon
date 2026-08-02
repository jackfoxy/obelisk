::  %obelisk-web: native Sail and HTTP boundary for Obelisk.
::
::  Direct Eyre routing keeps this small desk-local route surface explicit.
::
/-  ast=obelisk-ast, web=obelisk-web
/+  dbug, default-agent, json-lib=obelisk-web-json, server, web-lib=obelisk-web
|%
+$  card  card:agent:gall
+$  route-result
  $%  [%cards value=(list card)]
      [%obelisk request=web-request:web]
  ==
+$  work-plan
  $:  action=action:ast
      work-kind=obelisk-work-kind:web
      reply-kind=obelisk-reply-kind:web
  ==
::
++  connect-card
  |=  app=term
  ^-  card
  :*  %pass  /eyre/connect  %arvo  %e
      %connect  `/apps/obelisk  app
  ==
::
++  respond
  |=  $:  eyre-id=@ta
          status=@ud
          headers=(list [key=@t value=@t])
          body=@t
      ==
  ^-  (list card)
  %+  give-simple-payload:app:server  eyre-id
  ^-  simple-payload:http
  [[status headers] `(as-octt:mimes:html (trip body))]
::
++  api-operation-for
  |=  url=tape
  ^-  (unit api-operation:web)
  ?:  =("/apps/obelisk/api/run" url)  `%run
  ?:  =("/apps/obelisk/api/parse" url)  `%parse
  ?:  =("/apps/obelisk/api/schema" url)  `%schema
  ?:  =("/apps/obelisk/api/files/browse" url)  `%file-browse
  ?:  =("/apps/obelisk/api/files/load" url)  `%file-load
  ?:  =("/apps/obelisk/api/files/save" url)  `%file-save
  ~
::
++  make-error
  |=  [code=error-code:web status=@ud message=@t retryable=?]
  ^-  web-error:web
  [code status message retryable ~]
::
++  respond-error
  |=  [eyre-id=@ta error=web-error:web]
  ^-  (list card)
  (respond-error-with eyre-id error ~)
::
++  respond-error-with
  |=  $:  eyre-id=@ta
          error=web-error:web
          extra-headers=(list [key=@t value=@t])
      ==
  ^-  (list card)
  %:  respond
    eyre-id
    status.error
    %+  weld
      :~  ['content-type' 'application/json; charset=utf-8']
          ['cache-control' 'no-store']
          ['x-content-type-options' 'nosniff']
      ==
    extra-headers
    %-  json-text:json-lib
    (response-json:json-lib [%error error])
  ==
::
++  json-content-type
  |=  headers=header-list:http
  ^-  ?
  =/  content-type=(unit @t)
    (get-header:http 'content-type' headers)
  ?~  content-type  %.n
  =/  normalized=@t  (crip (cass (trip u.content-type)))
  ?|  =(normalized 'application/json')
      =(normalized 'application/json; charset=utf-8')
  ==
::
++  obelisk-backed
  |=  operation=api-operation:web
  ^-  ?
  ?|  =(%run operation)
      =(%parse operation)
      =(%schema operation)
  ==
::
++  readiness-wire
  |=  request-id=request-id:web
  ^-  wire
  /obelisk-web/readiness/(scot %ud request-id)
::
++  work-wire
  |=  [request-id=request-id:web attempt=@ud kind=term]
  ^-  wire
  [%obelisk-web %work (scot %ud request-id) (scot %ud attempt) kind ~]
::
++  wait-card
  |=  [=wire when=@da]
  ^-  card
  [%pass wire %arvo %b %wait when]
::
++  watch-card
  |=  [=wire our=@p]
  ^-  card
  [%pass wire %agent [our %obelisk] %watch /server]
::
++  leave-card
  |=  [=wire our=@p]
  ^-  card
  [%pass wire %agent [our %obelisk] %leave ~]
::
++  poke-card
  |=  [=wire our=@p action=action:ast]
  ^-  card
  :*  %pass  wire  %agent  [our %obelisk]
      %poke  %obelisk-action  !>(action)
  ==
::
++  work-for
  |=  request=web-request:web
  ^-  (unit work-plan)
  ?-  -.request
    %run
      =/  action=action:ast
        [%script default-database.request %vector (trip script.request)]
      `[action %run-script %query]
    %parse
      =/  action=action:ast
        [%parse default-database.request (trip script.request)]
      `[action %parse %parse]
    %schema  ~
    %file-browse  ~
    %file-load  ~
    %file-save  ~
  ==
::
++  coordinated-response
  |=  eyre-id=@ta
  ^-  (list card)
  %+  respond-error  eyre-id
  %:  make-error
    %unavailable
    503
    'Obelisk reply received; response decoding is starting'
    %.y
  ==
::
++  unavailable-response
  |=  eyre-id=@ta
  ^-  (list card)
  %:  respond-error-with
    eyre-id
    (make-error %unavailable 503 'Obelisk is temporarily unavailable' %.y)
    ~[['retry-after' '1']]
  ==
::
++  queue-full-response
  |=  eyre-id=@ta
  ^-  (list card)
  %+  respond-error  eyre-id
  (make-error %queue-full 429 'Obelisk request queue is full' %.y)
::
++  malformed-fact-response
  |=  eyre-id=@ta
  ^-  (list card)
  %+  respond-error  eyre-id
  (make-error %internal 500 'Obelisk returned a malformed reply' %.n)
::
++  lost-subscription-response
  |=  eyre-id=@ta
  ^-  (list card)
  %+  respond-error  eyre-id
  (make-error %unavailable 503 'Obelisk closed before replying' %.y)
::
++  timeout-response
  |=  eyre-id=@ta
  ^-  (list card)
  %+  respond-error  eyre-id
  (make-error %timeout 504 'Obelisk request timed out' %.y)
::
++  valid-obelisk-fact
  |=  =cage
  ^-  ?
  ?.  =(%noun p.cage)  %.n
  =/  decoded=(each [? *] tang)
    %-  mule  |.  !<([? *] q.cage)
  ?=(%.y -.decoded)
::
++  begin-readiness
  |=  [job=queued-request:web state=live-state:web our=@p]
  ^-  (quip card live-state:web)
  =/  retry-wire=wire  (readiness-wire request-id.job)
  =/  pending=pending-readiness:web  [job 0 retry-wire]
  =.  readiness.transient.state  `pending
  :_  state
  ~[(watch-card retry-wire our)]
::
++  start-next
  |=  [state=live-state:web now=@da our=@p]
  ^-  (quip card live-state:web)
  ?~  queue.transient.state
    :_  state
    ~
  =/  job=queued-request:web  i.queue.transient.state
  =/  next-state=live-state:web
    ^-(live-state:web state)
  =.  queue.transient.next-state  t.queue.transient.state
  (begin-readiness job next-state our)
::
++  start-active
  |=  $:  job=queued-request:web
          retries=@ud
          state=live-state:web
          now=@da
          our=@p
      ==
  ^-  (quip card live-state:web)
  =/  work=(unit work-plan)
    (work-for request.job)
  ?~  work
    =/  next=(quip card live-state:web)  (start-next state now our)
    :_  +.next
    (weld (coordinated-response eyre-id.job) -.next)
  =/  watch-wire=wire  (work-wire request-id.job retries %watch)
  =/  poke-wire=wire  (work-wire request-id.job retries %poke)
  =/  timeout-wire=wire  (work-wire request-id.job retries %timeout)
  =/  active=active-obelisk:web
    :*  job
        action.u.work
        work-kind.u.work
        reply-kind.u.work
        %watching
        watch-wire
        poke-wire
        timeout-wire
        retries
    ==
  =.  active.transient.state  `active
  :_  state
  :~  (watch-card watch-wire our)
      (wait-card timeout-wire (add now work-timeout:web-lib))
  ==
::
++  complete-active
  |=  $:  active=active-obelisk:web
          response-cards=(list card)
          cleanup=?
          state=live-state:web
          now=@da
          our=@p
      ==
  ^-  (quip card live-state:web)
  =.  active.transient.state  ~
  =/  next=(quip card live-state:web)  (start-next state now our)
  =/  cleanup-cards=(list card)
    ?:  cleanup  ~[(leave-card watch-wire.active our)]  ~
  :_  +.next
  (weld cleanup-cards (weld response-cards -.next))
::
++  advance-readiness
  |=  $:  pending=pending-readiness:web
          live=?
          state=live-state:web
          now=@da
          our=@p
      ==
  ^-  (quip card live-state:web)
  =/  decision=readiness-decision:web
    (readiness-step:web-lib live failures.pending)
  ?-  -.decision
    %ready
      =.  readiness.transient.state  ~
      (start-active job.pending failures.pending state now our)
    %retry
      =.  failures.pending  failures.decision
      =.  readiness.transient.state  `pending
      :_  state
      ~[(wait-card retry-wire.pending (add now readiness-delay:web-lib))]
    %exhausted
      =.  readiness.transient.state  ~
      =/  next=(quip card live-state:web)  (start-next state now our)
      :_  +.next
      (weld (unavailable-response eyre-id.job.pending) -.next)
  ==
::
++  retry-active
  |=  $:  active=active-obelisk:web
          cleanup=?
          state=live-state:web
          now=@da
          our=@p
      ==
  ^-  (quip card live-state:web)
  =/  decision=readiness-decision:web
    (readiness-step:web-lib %.n retries.active)
  =.  active.transient.state  ~
  =/  cleanup-cards=(list card)
    ?:  cleanup  ~[(leave-card watch-wire.active our)]  ~
  ?-  -.decision
    %ready  !!
    %retry
      =/  retry-wire=wire  (readiness-wire request-id.job.active)
      =/  pending=pending-readiness:web
        [job.active failures.decision retry-wire]
      =.  readiness.transient.state  `pending
      :_  state
      %+  weld  cleanup-cards
      ~[(wait-card retry-wire (add now readiness-delay:web-lib))]
    %exhausted
      =/  next=(quip card live-state:web)  (start-next state now our)
      :_  +.next
      %+  weld  cleanup-cards
      (weld (unavailable-response eyre-id.job.active) -.next)
  ==
::
++  accept-job
  |=  $:  eyre-id=@ta
          request=web-request:web
          state=live-state:web
          now=@da
          our=@p
      ==
  ^-  (quip card live-state:web)
  =/  busy=?
    ?|  ?=(^ readiness.transient.state)
        ?=(^ active.transient.state)
        ?=(^ queue.transient.state)
    ==
  ?:  ?&  busy
          !(queue-has-room:web-lib queue.transient.state)
      ==
    :_  state
    (queue-full-response eyre-id)
  =/  request-id=request-id:web  next-request-id.transient.state
  =/  job=queued-request:web  [request-id eyre-id now request]
  =.  next-request-id.transient.state  +(request-id)
  ?:  busy
    =.  queue.transient.state  (snoc queue.transient.state job)
    :_  state
    ~
  (begin-readiness job state our)
::
++  route-api
  |=  $:  eyre-id=@ta
          req=inbound-request:eyre
          operation=api-operation:web
      ==
  ^-  route-result
  ?.  =(%'POST' method.request.req)
    :-  %cards
    %:  respond-error-with
      eyre-id
      (make-error %bad-request 405 'method not allowed' %.n)
      ~[['allow' 'POST']]
    ==
  ?.  authenticated.req
    :-  %cards
    %+  respond-error  eyre-id
    (make-error %unauthorized 401 'authentication required' %.n)
  ?.  (json-content-type header-list.request.req)
    :-  %cards
    %+  respond-error  eyre-id
    %:  make-error
      %unsupported-media  415  'content-type must be application/json'  %.n
    ==
  ?~  body.request.req
    :-  %cards
    %+  respond-error  eyre-id
    (make-error %bad-request 400 'missing JSON body' %.n)
  ?:  (gth p.u.body.request.req max-body-bytes:json-lib)
    :-  %cards
    %+  respond-error  eyre-id
    (make-error %payload-too-large 413 'request body exceeds 1 MiB' %.n)
  =/  decoded=(unit web-request:web)
    (request-from-text:json-lib q.u.body.request.req)
  ?~  decoded
    :-  %cards
    %+  respond-error  eyre-id
    (make-error %bad-request 400 'malformed JSON request' %.n)
  ?.  (request-matches:json-lib operation u.decoded)
    :-  %cards
    %+  respond-error  eyre-id
    (make-error %bad-request 400 'request type does not match route' %.n)
  ?.  (obelisk-backed operation)
    :-  %cards
    %+  respond-error  eyre-id
    (make-error %unavailable 503 'file service is starting' %.y)
  [%obelisk u.decoded]
::
++  route-http
  |=  [eyre-id=@ta req=inbound-request:eyre]
  ^-  route-result
  =/  url=tape  (trip url.request.req)
  =/  method=method:http  method.request.req
  =/  operation=(unit api-operation:web)  (api-operation-for url)
  ?^  operation
    (route-api eyre-id req u.operation)
  =/  route=(unit [content-type=@t body=@t])
    ?:  ?|  =("/apps/obelisk" url)
            =("/apps/obelisk/" url)
        ==
      `['text/html; charset=utf-8' page:web-lib]
    ?:  =("/apps/obelisk/app.js" url)
      `['text/javascript; charset=utf-8' javascript:web-lib]
    ?:  =("/apps/obelisk/app.css" url)
      `['text/css; charset=utf-8' css:web-lib]
    ~
  ?~  route
    :-  %cards
    (respond eyre-id 404 ~[['content-type' 'text/plain']] 'not found')
  ?.  =(%'GET' method)
    :-  %cards
    %:  respond
      eyre-id
      405
      ~[['content-type' 'text/plain'] ['allow' 'GET']]
      'method not allowed'
    ==
  :-  %cards
  (respond eyre-id 200 ~[['content-type' content-type.u.route]] body.u.route)
--
%-  agent:dbug
=|  live-state:web
=*  state  -
^-  agent:gall
|_  =bowl:gall
+*  this     .
    default  ~(. (default-agent this %n) bowl)
::
++  on-init
  ^-  (quip card _this)
  =/  initial=live-state:web  empty-live-state:web-lib
  =.  binding.transient.initial  %bound
  :_  this(state initial)
  ~[(connect-card dap.bowl)]
::
++  on-save
  ^-  vase
  !>((save-state:web-lib state))
::
++  on-load
  |=  old-vase=vase
  ^-  (quip card _this)
  =/  loaded=(each live-state:web tang)
    (load-vase:web-lib old-vase)
  =/  next=live-state:web
    ?-  -.loaded
      %.y  p.loaded
      %.n
        %-  (slog 'obelisk-web state corrupt; using empty state' p.loaded)
        empty-live-state:web-lib
    ==
  =.  binding.transient.next  %bound
  :_  this(state next)
  ~[(connect-card dap.bowl)]
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?.  =(%handle-http-request mark)
    (on-poke:default mark vase)
  ?>  =(src.bowl our.bowl)
  =/  decoded=(each [eyre-id=@ta req=inbound-request:eyre] tang)
    %-  mule  |.  !<([@ta inbound-request:eyre] vase)
  ?.  ?=(%.y -.decoded)
    %-  (slog 'obelisk-web received malformed HTTP request' p.decoded)
    `this
  =/  [eyre-id=@ta req=inbound-request:eyre]  p.decoded
  =/  routed=route-result  (route-http eyre-id req)
  ?-  -.routed
    %cards
      :_  this
      value.routed
    %obelisk
      =/  accepted=(quip card live-state:web)
        %:  accept-job
          eyre-id
          request.routed
          state
          now.bowl
          our.bowl
        ==
      :_  this(state +.accepted)
      -.accepted
  ==
::
++  on-watch  on-watch:default
::
++  on-leave  on-leave:default
::
++  on-peek  on-peek:default
::
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  =/  pending=(unit pending-readiness:web)  readiness.transient.state
  ?:  ?&  ?=(^ pending)
          =(wire retry-wire.u.pending)
      ==
    ?-  -.sign
      %watch-ack
        =/  advanced=(quip card live-state:web)
          %:  advance-readiness
            u.pending
            ?~(p.sign %.y %.n)
            state
            now.bowl
            our.bowl
          ==
        :_  this(state +.advanced)
        ?~  p.sign
          (weld ~[(leave-card wire our.bowl)] -.advanced)
        -.advanced
      %kick
        =/  advanced=(quip card live-state:web)
          (advance-readiness u.pending %.n state now.bowl our.bowl)
        :_  this(state +.advanced)
        -.advanced
      %fact  `this
      %poke-ack  `this
    ==
  ?~  active.transient.state
    ?:  ?=([%obelisk-web %work *] wire)
      `this
    (on-agent:default wire sign)
  =/  active=active-obelisk:web  u.active.transient.state
  ?:  =(wire watch-wire.active)
    ?-  -.sign
      %watch-ack
        ?^  p.sign
          =/  retried=(quip card live-state:web)
            %:  retry-active
              active  %.n  state  now.bowl  our.bowl
            ==
          :_  this(state +.retried)
          -.retried
        ?.  =(%watching phase.active)  `this
        =.  phase.active  %poking
        =.  active.transient.state  `active
        :_  this(state state)
        ~[(poke-card poke-wire.active our.bowl action.active)]
      %fact
        =/  response-cards=(list card)
          ?:  ?&  !=(%watching phase.active)
                  (valid-obelisk-fact cage.sign)
              ==
            (coordinated-response eyre-id.job.active)
          (malformed-fact-response eyre-id.job.active)
        =/  completed=(quip card live-state:web)
          %:  complete-active
            active
            response-cards
            %.y
            state
            now.bowl
            our.bowl
          ==
        :_  this(state +.completed)
        -.completed
      %kick
        =/  completed=(quip card live-state:web)
          %:  complete-active
            active
            (lost-subscription-response eyre-id.job.active)
            %.n
            state
            now.bowl
            our.bowl
          ==
        :_  this(state +.completed)
        -.completed
      %poke-ack  `this
    ==
  ?:  =(wire poke-wire.active)
    ?-  -.sign
      %poke-ack
        ?^  p.sign
          =/  retried=(quip card live-state:web)
            %:  retry-active
              active  %.y  state  now.bowl  our.bowl
            ==
          :_  this(state +.retried)
          -.retried
        ?.  =(%poking phase.active)  `this
        =.  phase.active  %waiting
        =.  active.transient.state  `active
        `this(state state)
      %watch-ack  `this
      %kick  `this
      %fact  `this
    ==
  ?:  ?=([%obelisk-web %work *] wire)
    `this
  (on-agent:default wire sign)
::
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
  ?:  ?=([%obelisk-web %readiness *] wire)
    ?~  readiness.transient.state  `this
    =/  pending=pending-readiness:web  u.readiness.transient.state
    ?.  =(wire retry-wire.pending)  `this
    ?.  ?=([%behn %wake *] sign-arvo)
      (on-arvo:default wire sign-arvo)
    ?~  error.sign-arvo
      :_  this
      ~[(watch-card wire our.bowl)]
    =/  advanced=(quip card live-state:web)
      %:  advance-readiness
        pending  %.n  state  now.bowl  our.bowl
      ==
    :_  this(state +.advanced)
    -.advanced
  ?:  ?=([%obelisk-web %work *] wire)
    ?~  active.transient.state  `this
    =/  active=active-obelisk:web  u.active.transient.state
    ?.  =(wire timeout-wire.active)  `this
    ?.  ?=([%behn %wake *] sign-arvo)
      (on-arvo:default wire sign-arvo)
    =/  completed=(quip card live-state:web)
      %:  complete-active
        active
        (timeout-response eyre-id.job.active)
        %.y
        state
        now.bowl
        our.bowl
      ==
    :_  this(state +.completed)
    -.completed
  (on-arvo:default wire sign-arvo)
::
++  on-fail  on-fail:default
--
