::  %obelisk-web: native Sail and HTTP boundary for Obelisk.
::
::  Direct Eyre routing keeps this small desk-local route surface explicit.
::
/-  web=obelisk-web
/+  dbug, default-agent, json-lib=obelisk-web-json, server, web-lib=obelisk-web
|%
+$  card  card:agent:gall
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
++  route-api
  |=  $:  eyre-id=@ta
          req=inbound-request:eyre
          operation=api-operation:web
      ==
  ^-  (list card)
  ?.  =(%'POST' method.request.req)
    %:  respond-error-with
      eyre-id
      (make-error %bad-request 405 'method not allowed' %.n)
      ~[['allow' 'POST']]
    ==
  ?.  authenticated.req
    %+  respond-error  eyre-id
    (make-error %unauthorized 401 'authentication required' %.n)
  ?.  (json-content-type header-list.request.req)
    %+  respond-error  eyre-id
    %:  make-error
      %unsupported-media  415  'content-type must be application/json'  %.n
    ==
  ?~  body.request.req
    %+  respond-error  eyre-id
    (make-error %bad-request 400 'missing JSON body' %.n)
  ?:  (gth p.u.body.request.req max-body-bytes:json-lib)
    %+  respond-error  eyre-id
    %:  make-error
      %payload-too-large  413  'request body exceeds 1 MiB'  %.n
    ==
  =/  decoded=(unit web-request:web)
    (request-from-text:json-lib q.u.body.request.req)
  ?~  decoded
    %+  respond-error  eyre-id
    (make-error %bad-request 400 'malformed JSON request' %.n)
  ?.  (request-matches:json-lib operation u.decoded)
    %+  respond-error  eyre-id
    (make-error %bad-request 400 'request type does not match route' %.n)
  %+  respond-error  eyre-id
  %:  make-error
    %unavailable  503  'Obelisk web service is starting'  %.y
  ==
::
++  route-http
  |=  [eyre-id=@ta req=inbound-request:eyre]
  ^-  (list card)
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
    (respond eyre-id 404 ~[['content-type' 'text/plain']] 'not found')
  ?.  =(%'GET' method)
    %:  respond
      eyre-id
      405
      ~[['content-type' 'text/plain'] ['allow' 'GET']]
      'method not allowed'
    ==
  %-  respond
  [eyre-id 200 ~[['content-type' content-type.u.route]] body.u.route]
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
  :_  this
  (route-http eyre-id req)
::
++  on-watch  on-watch:default
::
++  on-leave  on-leave:default
::
++  on-peek  on-peek:default
::
++  on-agent  on-agent:default
::
++  on-arvo  on-arvo:default
::
++  on-fail  on-fail:default
--
