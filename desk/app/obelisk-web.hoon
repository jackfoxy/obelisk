::  %obelisk-web: native Sail and HTTP boundary for Obelisk.
::
::  Direct Eyre routing keeps this small desk-local route surface explicit.
::
/-  web=obelisk-web
/+  dbug, default-agent, json-lib=obelisk-web-json, server, web-lib=obelisk-web
|%
+$  card  card:agent:gall
+$  route-result
  $%  [%cards value=(list card)]
      [%obelisk request=web-request:web]
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
++  ready-response
  |=  eyre-id=@ta
  ^-  (list card)
  %+  respond-error  eyre-id
  %:  make-error
    %unavailable
    503
    'Obelisk is ready; request execution is starting'
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
++  begin-readiness
  |=  [job=queued-request:web state=live-state:web our=@p]
  ^-  (quip card live-state:web)
  =/  retry-wire=wire  (readiness-wire request-id.job)
  =/  pending=pending-readiness:web  [job 0 retry-wire]
  =.  readiness.transient.state  `pending
  :_  state
  ~[(watch-card retry-wire our)]
::
++  advance-readiness
  |=  [pending=pending-readiness:web live=? state=live-state:web now=@da]
  ^-  (quip card live-state:web)
  =/  decision=readiness-decision:web
    (readiness-step:web-lib live failures.pending)
  ?-  -.decision
    %ready
      =.  readiness.transient.state  ~
      :_  state
      (ready-response eyre-id.job.pending)
    %retry
      =.  failures.pending  failures.decision
      =.  readiness.transient.state  `pending
      :_  state
      ~[(wait-card retry-wire.pending (add now readiness-delay:web-lib))]
    %exhausted
      =.  readiness.transient.state  ~
      :_  state
      (unavailable-response eyre-id.job.pending)
  ==
::
++  retry-active
  |=  [active=active-obelisk:web state=live-state:web now=@da]
  ^-  (quip card live-state:web)
  =/  decision=readiness-decision:web
    (readiness-step:web-lib %.n retries.active)
  =.  active.transient.state  ~
  ?-  -.decision
    %ready  !!
    %retry
      =/  retry-wire=wire  (readiness-wire request-id.job.active)
      =/  pending=pending-readiness:web
        [job.active failures.decision retry-wire]
      =.  readiness.transient.state  `pending
      :_  state
      ~[(wait-card retry-wire (add now readiness-delay:web-lib))]
    %exhausted
      :_  state
      (unavailable-response eyre-id.job.active)
  ==
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
      ?^  readiness.transient.state
        :_  this
        (unavailable-response eyre-id)
      =/  request-id=request-id:web  next-request-id.transient.state
      =/  job=queued-request:web
        [request-id eyre-id now.bowl request.routed]
      =.  next-request-id.transient.state  +(request-id)
      =/  started=(quip card live-state:web)
        (begin-readiness job state our.bowl)
      :_  this(state +.started)
      -.started
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
          (advance-readiness u.pending ?~(p.sign %.y %.n) state now.bowl)
        :_  this(state +.advanced)
        ?~  p.sign
          (weld ~[(leave-card wire our.bowl)] -.advanced)
        -.advanced
      %kick
        =/  advanced=(quip card live-state:web)
          (advance-readiness u.pending %.n state now.bowl)
        :_  this(state +.advanced)
        -.advanced
      %fact  `this
      %poke-ack  `this
    ==
  ?~  active.transient.state
    (on-agent:default wire sign)
  =/  active=active-obelisk:web  u.active.transient.state
  ?.  =(wire obelisk-wire.active)
    (on-agent:default wire sign)
  ?-  -.sign
    %poke-ack
      ?~  p.sign
        `this
      =/  retried=(quip card live-state:web)
        (retry-active active state now.bowl)
      :_  this(state +.retried)
      -.retried
    %watch-ack
      ?~  p.sign
        `this
      =/  retried=(quip card live-state:web)
        (retry-active active state now.bowl)
      :_  this(state +.retried)
      -.retried
    %kick  (on-agent:default wire sign)
    %fact  (on-agent:default wire sign)
  ==
::
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
  ?.  ?=([%obelisk-web %readiness *] wire)
    (on-arvo:default wire sign-arvo)
  ?~  readiness.transient.state
    `this
  =/  pending=pending-readiness:web  u.readiness.transient.state
  ?.  =(wire retry-wire.pending)
    `this
  ?.  ?=([%behn %wake *] sign-arvo)
    (on-arvo:default wire sign-arvo)
  ?~  error.sign-arvo
    :_  this
    ~[(watch-card wire our.bowl)]
  =/  advanced=(quip card live-state:web)
    (advance-readiness pending %.n state now.bowl)
  :_  this(state +.advanced)
  -.advanced
::
++  on-fail  on-fail:default
--
