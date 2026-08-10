::  %obelisk-web: native Sail and HTTP boundary for Obelisk.
::
::  Direct Eyre routing keeps this small desk-local route surface explicit.
::
/-  ast=obelisk-ast, web=obelisk-web
/+  dbug, default-agent, server
/+  file-lib=obelisk-web-file
/+  json-lib=obelisk-web-json, result-lib=obelisk-web-result
/+  readiness-lib=readiness-state
/+  schema-lib=obelisk-web-schema
/+  web-lib=obelisk-web
|%
+$  card  card:agent:gall
+$  route-result
  $%  [%cards value=(list card)]
      [%obelisk request=web-request:web]
      [%file request=web-request:web]
  ==
+$  work-plan  work-plan:readiness-lib
+$  query-reply  (each (list cmd-result:ast) tang)
+$  parse-reply  (each (list command:ast) tang)
+$  decoded-reply
  $%  [%query reply=query-reply]
      [%parse reply=parse-reply]
      [%malformed ~]
  ==
::
++  connect-card
  |=  app=term
  ^-  card
  [%pass /eyre/connect %arvo %e %connect `/apps/obelisk app]
::
++  json-headers
  ^-  (list [key=@t value=@t])
  :~  ['content-type' 'application/json; charset=utf-8']
      ['cache-control' 'no-store']
      ['x-content-type-options' 'nosniff']
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
    (weld json-headers extra-headers)
    (json-text:json-lib (response-json:json-lib [%error error]))
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
  |=  [request-id=request-id:web attempt=@ud stage=@ud kind=term]
  ^-  wire
  :~  %obelisk-web
      %work
      (scot %ud request-id)
      (scot %ud attempt)
      (scot %ud stage)
      kind
  ==
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
  [%pass wire %agent [our %obelisk] %poke %obelisk-action !>(action)]
::
++  work-for
  ::  File requests are served locally, so they plan no Obelisk work.
  ::
  |=  request=web-request:web
  ^-  (unit work-plan)
  ?-  -.request
    ?(%file-browse %file-load %file-save)  ~
    ?(%run %parse)
      =/  action=action:ast
        [%parse default-database.request (trip script.request)]
      =/  kind=obelisk-work-kind:web
        ?:(?=(%run -.request) %run-parse %parse)
      `[action kind %parse [%none ~]]
    %schema
      =/  action=action:ast
        [%script %sys %vector databases-query:schema-lib]
      `[action %schema %query [%schema-databases default-database.request]]
  ==
::
++  decode-reply
  |=  [kind=obelisk-reply-kind:web =cage]
  ^-  decoded-reply
  ?.  =(%noun p.cage)  [%malformed ~]
  ?-  kind
    %query
      =/  decoded=(each query-reply tang)
        (mule |.(;;(query-reply q.q.cage)))
      ?.  ?=(%.y -.decoded)  [%malformed ~]
      [%query p.decoded]
    %parse
      =/  decoded=(each parse-reply tang)
        (mule |.(;;(parse-reply q.q.cage)))
      ?.  ?=(%.y -.decoded)  [%malformed ~]
      [%parse p.decoded]
  ==
::
++  respond-json
  |=  [eyre-id=@ta response=web-response:web]
  ^-  (list card)
  %:  respond
    eyre-id
    200
    json-headers
    (json-text:json-lib (response-json:json-lib response))
  ==
::
++  file-error-cards
  |=  [eyre-id=@ta message=@t trace=tang]
  ^-  (list card)
  %+  respond-error  eyre-id
  [%internal 500 message %.n (tang-details:result-lib trace)]
::
++  clay-exists
  |=  beam=path
  ^-  (each ? tang)
  %-  mule  |.
  .^(? %cx (tomb-beam:file-lib beam))
::
++  clay-physical-paths
  ::  Every stored file at or under +clay-path, node before its children.
  ::
  |=  [our=@p desk=desk now=@da clay-path=path]
  ^-  (each (list path) tang)
  ::  Each recursive result is bound to a typed =/ before +weld sees it:
  ::  +weld is wet, and mulling it against the in-progress trap type
  ::  loops.
  ::
  %-  mule  |.
  |-  ^-  (list path)
  =/  =arch  .^(arch %cy (clay-beam:file-lib our desk da+now clay-path))
  =/  here=(list path)  ?~(fil.arch ~ ~[clay-path])
  =/  names=(list @ta)  (sort ~(tap in ~(key by dir.arch)) aor)
  =/  children=(list path)
    |-  ^-  (list path)
    ?~  names  ~
    =/  head=(list path)  ^$(clay-path (snoc clay-path i.names))
    =/  rest=(list path)  $(names t.names)
    (weld head rest)
  (weld here children)
::
++  browse-file-cards
  |=  $:  eyre-id=@ta
          relative=relative-path:web
          our=@p
          desk=desk
          now=@da
      ==
  ^-  (list card)
  ?.  (valid-browse-path:file-lib relative)
    %+  respond-error  eyre-id
    (make-error %bad-request 400 'invalid file browse path' %.n)
  =/  clay-path=path  (browse-path:file-lib relative)
  =/  loaded=(each (list path) tang)
    (clay-physical-paths our desk now clay-path)
  ?:  ?=(%.n -.loaded)
    (file-error-cards eyre-id 'Clay browse failed' p.loaded)
  =/  entries=(list file-entry-dto:web)
    (entries-from-physical:file-lib relative p.loaded)
  (respond-json eyre-id [%file-list entries])
::
++  load-file-cards
  |=  $:  eyre-id=@ta
          relative=relative-path:web
          our=@p
          desk=desk
          now=@da
      ==
  ^-  (list card)
  ?.  (valid-file-path:file-lib relative)
    %+  respond-error  eyre-id
    (make-error %bad-request 400 'invalid file path' %.n)
  =/  clay-path=path  (storage-path:file-lib relative)
  =/  beam=path
    (clay-beam:file-lib our desk da+now clay-path)
  =/  exists=(each ? tang)  (clay-exists beam)
  ?:  ?=(%.n -.exists)
    (file-error-cards eyre-id 'Clay load failed' p.exists)
  ?.  p.exists
    %+  respond-error  eyre-id
    (make-error %not-found 404 'saved file not found' %.n)
  =/  loaded=(each @t tang)
    %-  mule  |.
    (of-wain:format .^(wain %cx beam))
  ?:  ?=(%.n -.loaded)
    (file-error-cards eyre-id 'Clay load failed' p.loaded)
  (respond-json eyre-id [%file relative p.loaded])
::
++  file-verify-card
  |=  [=wire our=@p desk=desk now=@da clay-path=path]
  ^-  card
  [%pass wire %arvo %c %warp our desk ~ %next %x da+now clay-path]
::
++  file-write-card
  |=  [=wire desk=desk clay-path=path content=@t]
  ^-  card
  :*  %pass  wire  %arvo  %c
      %info  desk  %&
      ~[[clay-path %ins (text-cage:file-lib content)]]
  ==
::
++  cancel-file-verify-card
  |=  [=wire our=@p desk=desk]
  ^-  card
  [%pass wire %arvo %c %warp our desk ~]
::
++  save-file
  |=  $:  eyre-id=@ta
          relative=relative-path:web
          content=@t
          overwrite=?
          state=live-state:web
          our=@p
          desk=desk
          now=@da
      ==
  ^-  (quip card live-state:web)
  ?.  (valid-file-path:file-lib relative)
    :_  state
    %+  respond-error  eyre-id
    (make-error %bad-request 400 'invalid file path' %.n)
  ::  Copy the slot out first: testing it in place would narrow +state.
  ::
  =/  current=(unit pending-file-save:web)  file-save.transient.state
  ?^  current
    :_  state
    %+  respond-error  eyre-id
    (make-error %unavailable 503 'another file save is pending' %.y)
  =/  clay-path=path  (storage-path:file-lib relative)
  =/  beam=path
    (clay-beam:file-lib our desk da+now clay-path)
  =/  exists=(each ? tang)  (clay-exists beam)
  ?:  ?=(%.n -.exists)
    :_  state
    (file-error-cards eyre-id 'Clay save check failed' p.exists)
  ?:  (save-conflict:file-lib p.exists overwrite)
    :_  state
    %+  respond-error  eyre-id
    (make-error %conflict 409 'saved file already exists' %.n)
  =/  request-id=request-id:web  next-request-id.transient.state
  =/  verify-wire=wire
    /obelisk-web/file-save/(scot %ud request-id)/verify
  =/  write-wire=wire
    /obelisk-web/file-save/(scot %ud request-id)/write
  =/  timeout-wire=wire
    /obelisk-web/file-save/(scot %ud request-id)/timeout
  =/  pending=pending-file-save:web
    [eyre-id relative content verify-wire timeout-wire desk]
  =.  next-request-id.transient.state  +(request-id)
  =.  file-save.transient.state  `pending
  :_  state
  :~  (file-verify-card verify-wire our desk now clay-path)
      (file-write-card write-wire desk clay-path content)
      (wait-card timeout-wire (add now file-timeout:file-lib))
  ==
::
++  complete-file-save
  |=  $:  pending=pending-file-save:web
          =sign-arvo
          state=live-state:web
      ==
  ^-  (quip card live-state:web)
  =/  result=riot:clay
    ?.  ?=([%clay %writ *] sign-arvo)  ~
    +.+.sign-arvo
  =/  valid=?  (save-verifies:file-lib content.pending result)
  =.  file-save.transient.state  ~
  :_  state
  ?:  valid
    (respond-json eyre-id.pending [%saved path.pending])
  (file-error-cards eyre-id.pending 'Clay save verification failed' ~)
::
++  handle-file-request
  |=  $:  eyre-id=@ta
          request=web-request:web
          state=live-state:web
          our=@p
          desk=desk
          now=@da
      ==
  ^-  (quip card live-state:web)
  ?-  -.request
    %file-browse
      :_  state
      (browse-file-cards eyre-id path.request our desk now)
    %file-load
      :_  state
      (load-file-cards eyre-id path.request our desk now)
    %file-save
      %:  save-file
        eyre-id
        path.request
        content.request
        overwrite.request
        state
        our
        desk
        now
      ==
    ?(%run %parse %schema)  !!
  ==
::
++  reply-error-cards
  |=  [eyre-id=@ta kind=obelisk-reply-kind:web trace=tang]
  ^-  (list card)
  =/  message=@t
    ?-(kind %query 'Obelisk execution failed', %parse 'urQL parse failed')
  %+  respond-error  eyre-id
  [%unprocessable 422 message %.n (tang-details:result-lib trace)]
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
++  readiness-dependencies
  ^-  dependencies:readiness-lib
  :*  readiness-wire
      work-wire
      wait-card
      watch-card
      leave-card
      work-for
      coordinated-response
      unavailable-response
  ==
::
++  readiness-controller
  ~(. controller:readiness-lib readiness-dependencies)
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
++  complete-with-response
  |=  $:  active=active-obelisk:web
          response=web-response:web
          state=live-state:web
          now=@da
          our=@p
      ==
  ^-  (quip card live-state:web)
  %:  complete-active:readiness-controller
    active
    (respond-json eyre-id.job.active response)
    %.y
    state
    now
    our
  ==
::
++  complete-with-malformed
  |=  $:  active=active-obelisk:web
          state=live-state:web
          now=@da
          our=@p
      ==
  ^-  (quip card live-state:web)
  %:  complete-active:readiness-controller
    active
    (malformed-fact-response eyre-id.job.active)
    %.y
    state
    now
    our
  ==
::
++  complete-with-error
  |=  $:  active=active-obelisk:web
          kind=obelisk-reply-kind:web
          trace=tang
          state=live-state:web
          now=@da
          our=@p
      ==
  ^-  (quip card live-state:web)
  %:  complete-active:readiness-controller
    active
    (reply-error-cards eyre-id.job.active kind trace)
    %.y
    state
    now
    our
  ==
::
++  handle-parse-success
  |=  $:  active=active-obelisk:web
          commands=(list command:ast)
          state=live-state:web
          now=@da
          our=@p
      ==
  ^-  (quip card live-state:web)
  ?-  work-kind.active
    %parse
      %:  complete-with-response
        active
        (parse-response:result-lib commands)
        state
        now
        our
      ==
    %run-parse
      ?>  ?=(%run -.request.job.active)
      =/  action=action:ast
        :*  %script
            default-database.request.job.active
            %vector
            (trip script.request.job.active)
        ==
      =/  work=work-plan
        [action %run-script %query [%run commands]]
      (continue-active:readiness-controller active work state now our)
    ?(%run-script %schema)  (complete-with-malformed active state now our)
  ==
::
++  handle-schema-databases
  |=  $:  active=active-obelisk:web
          commands=(list cmd-result:ast)
          requested=(unit @tas)
          state=live-state:web
          now=@da
          our=@p
      ==
  ^-  (quip card live-state:web)
  =/  databases=(unit (list @tas))
    (database-names:schema-lib commands)
  ?~  databases
    (complete-with-malformed active state now our)
  =/  script=tape  (detail-script:schema-lib u.databases)
  ?~  script
    =/  response=(unit web-response:web)
      (schema-response:schema-lib requested u.databases ~)
    ?~  response
      (complete-with-malformed active state now our)
    (complete-with-response active u.response state now our)
  =/  action=action:ast  [%script %sys %vector script]
  =/  work=work-plan
    :*  action
        %schema
        %query
        [%schema-details requested u.databases]
    ==
  (continue-active:readiness-controller active work state now our)
::
++  handle-query-success
  |=  $:  active=active-obelisk:web
          commands=(list cmd-result:ast)
          state=live-state:web
          now=@da
          our=@p
      ==
  ^-  (quip card live-state:web)
  ?-  work-kind.active
    %run-script
      ?.  ?=(%run -.context.active)
        (complete-with-malformed active state now our)
      =/  changed=?
        (schema-changing:schema-lib commands.context.active)
      %:  complete-with-response
        active
        (run-response-with:result-lib commands changed)
        state
        now
        our
      ==
    %schema
      ?-  -.context.active
        %schema-databases
          %:  handle-schema-databases
            active
            commands
            requested.context.active
            state
            now
            our
          ==
        %schema-details
          =/  response=(unit web-response:web)
            %:  schema-response:schema-lib
              requested.context.active
              databases.context.active
              commands
            ==
          ?~  response
            (complete-with-malformed active state now our)
          (complete-with-response active u.response state now our)
        ?(%none %run)  (complete-with-malformed active state now our)
      ==
    ?(%run-parse %parse)  (complete-with-malformed active state now our)
  ==
::
++  handle-active-fact
  |=  $:  active=active-obelisk:web
          cage=cage
          state=live-state:web
          now=@da
          our=@p
      ==
  ^-  (quip card live-state:web)
  ?:  =(%watching phase.active)
    (complete-with-malformed active state now our)
  =/  decoded=decoded-reply
    (decode-reply reply-kind.active cage)
  ?-  -.decoded
    %malformed  (complete-with-malformed active state now our)
    %parse
      ?:  ?=(%.n -.reply.decoded)
        (complete-with-error active %parse p.reply.decoded state now our)
      (handle-parse-success active p.reply.decoded state now our)
    %query
      ?:  ?=(%.n -.reply.decoded)
        (complete-with-error active %query p.reply.decoded state now our)
      (handle-query-success active p.reply.decoded state now our)
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
    [~ state]
  (begin-readiness:readiness-controller job state our)
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
  ?:  (obelisk-backed operation)
    [%obelisk u.decoded]
  [%file u.decoded]
::
++  route-http
  |=  [eyre-id=@ta req=inbound-request:eyre our=@p desk=desk now=@da]
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
      `['text/html; charset=utf-8' (page:web-lib our)]
    ?:  =("/apps/obelisk/app.js" url)
      `['text/javascript; charset=utf-8' javascript:web-lib]
    ?:  =("/apps/obelisk/app.css" url)
      `['text/css; charset=utf-8' css:web-lib]
    ?:  =("/apps/obelisk/favicon.png" url)
      =/  beam=path  (clay-beam:file-lib our desk da+now /favicon/png)
      =/  loaded=(each @ tang)
        %-  mule  |.
        .^(@ %cx beam)
      ?:(?=(%.n -.loaded) ~ `['image/png' ^-(@t p.loaded)])
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
  =.  binding.transient.initial  %binding
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
    ?:  ?=(%.y -.loaded)  p.loaded
    %-  (slog 'obelisk-web state corrupt; using empty state' p.loaded)
    empty-live-state:web-lib
  =.  binding.transient.next  %binding
  :_  this(state next)
  ~[(connect-card dap.bowl)]
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?.  =(%handle-http-request mark)
    (on-poke:default mark vase)
  =/  decoded=(each [eyre-id=@ta req=inbound-request:eyre] tang)
    %-  mule  |.  !<([@ta inbound-request:eyre] vase)
  ?.  ?=(%.y -.decoded)
    %-  (slog 'obelisk-web received malformed HTTP request' p.decoded)
    `this
  =/  [eyre-id=@ta req=inbound-request:eyre]  p.decoded
  ::  Public assets use an Eyre guest identity; protected work must be local.
  ?>  ?|  !authenticated.req
          =(src.bowl our.bowl)
      ==
  =/  routed=route-result
    (route-http eyre-id req our.bowl q.byk.bowl now.bowl)
  ?-  -.routed
    %cards  [value.routed this]
    %obelisk
      =^  cards  state
        (accept-job eyre-id request.routed state now.bowl our.bowl)
      [cards this]
    %file
      =^  cards  state
        %:  handle-file-request
          eyre-id
          request.routed
          state
          our.bowl
          q.byk.bowl
          now.bowl
        ==
      [cards this]
  ==
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?+  path  (on-watch:default path)
    [%http-response @ ~]  `this
  ==
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
      ?(%fact %poke-ack)  `this
      %watch-ack
        =^  cards  state
          %:  advance-readiness:readiness-controller
            u.pending
            ?~(p.sign %.y %.n)
            state
            now.bowl
            our.bowl
          ==
        :_  this
        ?~  p.sign  [(leave-card wire our.bowl) cards]
        cards
      %kick
        =^  cards  state
          %:  advance-readiness:readiness-controller
            u.pending
            %.n
            state
            now.bowl
            our.bowl
          ==
        [cards this]
    ==
  ::  Copy the slot out first: testing it in place would narrow +state.
  ::
  =/  current=(unit active-obelisk:web)  active.transient.state
  ?~  current
    ?:  ?=([%obelisk-web %work *] wire)
      `this
    (on-agent:default wire sign)
  =/  active=active-obelisk:web  u.current
  ?:  =(wire watch-wire.active)
    ?-  -.sign
      %poke-ack  `this
      %watch-ack
        ?^  p.sign
          =^  cards  state
            %:  retry-active:readiness-controller
              active
              %.n
              state
              now.bowl
              our.bowl
            ==
          [cards this]
        ?.  =(%watching phase.active)  `this
        =.  phase.active  %poking
        =.  active.transient.state  `active
        :_  this
        ~[(poke-card poke-wire.active our.bowl action.active)]
      %fact
        =^  cards  state
          (handle-active-fact active cage.sign state now.bowl our.bowl)
        [cards this]
      %kick
        =^  cards  state
          %:  complete-active:readiness-controller
            active
            (lost-subscription-response eyre-id.job.active)
            %.n
            state
            now.bowl
            our.bowl
          ==
        [cards this]
    ==
  ?:  =(wire poke-wire.active)
    ?-  -.sign
      ?(%watch-ack %kick %fact)  `this
      %poke-ack
        ?^  p.sign
          =^  cards  state
            %:  retry-active:readiness-controller
              active
              %.y
              state
              now.bowl
              our.bowl
            ==
          [cards this]
        ?.  =(%poking phase.active)  `this
        =.  phase.active  %waiting
        =.  active.transient.state  `active
        `this
    ==
  ?:  ?=([%obelisk-web %work *] wire)
    `this
  (on-agent:default wire sign)
::
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
  ?:  =(wire /eyre/connect)
    ?.  ?=([%eyre %bound *] sign-arvo)
      (on-arvo:default wire sign-arvo)
    =.  binding.transient.state
      (binding-after-connect:web-lib accepted.sign-arvo)
    `this
  =/  pending=(unit pending-file-save:web)  file-save.transient.state
  ?:  ?&  ?=(^ pending)
          =(wire verify-wire.u.pending)
      ==
    =^  cards  state  (complete-file-save u.pending sign-arvo state)
    [cards this]
  ?:  ?&  ?=(^ pending)
          =(wire timeout-wire.u.pending)
      ==
    ?.  ?=([%behn %wake *] sign-arvo)
      (on-arvo:default wire sign-arvo)
    =/  cancel=card
      (cancel-file-verify-card verify-wire.u.pending our.bowl desk.u.pending)
    =.  file-save.transient.state  ~
    :_  this
    :-  cancel
    %+  respond-error  eyre-id.u.pending
    (make-error %timeout 504 'Clay save timed out' %.y)
  ?:  ?=([%obelisk-web %readiness *] wire)
    =/  current=(unit pending-readiness:web)  readiness.transient.state
    ?~  current  `this
    =/  pending=pending-readiness:web  u.current
    ?.  =(wire retry-wire.pending)  `this
    ?.  ?=([%behn %wake *] sign-arvo)
      (on-arvo:default wire sign-arvo)
    ?~  error.sign-arvo
      :_  this
      ~[(watch-card wire our.bowl)]
    =^  cards  state
      %:  advance-readiness:readiness-controller
        pending
        %.n
        state
        now.bowl
        our.bowl
      ==
    [cards this]
  ?:  ?=([%obelisk-web %work *] wire)
    =/  current=(unit active-obelisk:web)  active.transient.state
    ?~  current  `this
    =/  active=active-obelisk:web  u.current
    ?.  =(wire timeout-wire.active)  `this
    ?.  ?=([%behn %wake *] sign-arvo)
      (on-arvo:default wire sign-arvo)
    =^  cards  state
      %:  complete-active:readiness-controller
        active
        (timeout-response eyre-id.job.active)
        %.y
        state
        now.bowl
        our.bowl
      ==
    [cards this]
  ?:  ?=([%obelisk-web %file-save *] wire)
    `this
  (on-arvo:default wire sign-arvo)
::
++  on-fail  on-fail:default
--
