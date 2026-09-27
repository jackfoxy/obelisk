::  %obelisk-web: native Sail and HTTP boundary for Obelisk.
::
::  Direct Eyre routing keeps this small desk-local route surface explicit.
::
/-  ast=obelisk-ast, web=obelisk-web
/+  dbug, default-agent, server
/+  json-lib=obelisk-web-json, result-lib=obelisk-web-result
/+  readiness-lib=readiness-state
/+  schema-lib=obelisk-web-schema
/+  web-lib=obelisk-web
/+  uhttp=urui-http, ufiles=urui-files
/*  favicon      %ico  /favicon/ico
/*  docs-toc     %toc  /doc/toc
/*  ace-core     %js   /web/ace/ace/js
/*  ace-light    %js   /web/ace/theme-github/js
/*  ace-dark     %js   /web/ace/theme-monokai/js
/*  ace-beaut    %js   /web/ace/ext-beautify/js
/*  ace-prompt   %js   /web/ace/ext-prompt/js
/*  ace-search   %js   /web/ace/ext-searchbox/js
/*  ace-sets     %js   /web/ace/ext-settings-menu/js
/*  ace-vim      %js   /web/ace/keybinding-vim/js
/*  ace-lic      %txt  /web/ace/license/txt
|%
+$  card  card:agent:gall
+$  route-result
  $%  [%cards value=(list card)]
      [%obelisk request=web-request:web]
      [%files req=inbound-request:eyre]
      [%result-save request=web-request:web]
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
++  respond-octs
  |=  $:  eyre-id=@ta
          status=@ud
          headers=(list [key=@t value=@t])
          body=octs
      ==
  ^-  (list card)
  %+  give-simple-payload:app:server  eyre-id
  ^-  simple-payload:http
  [[status headers] `body]
::
++  assets
  ::  Static GET routes under /apps/obelisk.  The page is not here: it
  ::  is built per request from the ship's @p, and so is `app.js`,
  ::  whose emitted config carries the same pane spec.
  |=  our=@p
  ^-  (list [suffix=@t asset=asset:uhttp])
  =/  js=@t  'text/javascript; charset=utf-8'
  =/  text=@t  'text/plain; charset=utf-8'
  %+  turn
    :~  ['/app.js' js (javascript:web-lib our)]
        ['/app.css' 'text/css; charset=utf-8' css:web-lib]
        ['/doc.toc' text docs-toc]
        ['/ace/ace.js' js ace-core]
        ['/ace/obelisk-config.js' js ace-config-js:web-lib]
        ['/ace/theme-github.js' js ace-light]
        ['/ace/theme-monokai.js' js ace-dark]
        ['/ace/ext-beautify.js' js ace-beaut]
        ['/ace/ext-prompt.js' js ace-prompt]
        ['/ace/ext-searchbox.js' js ace-search]
        ['/ace/ext-settings_menu.js' js ace-sets]
        ['/ace/keybinding-vim.js' js ace-vim]
        ['/ace/license.txt' text (of-wain:format ace-lic)]
    ==
  |=  [suffix=@t content-type=@t body=@t]
  [suffix content-type (as-octs:mimes:html body)]
::
++  api-operation-for
  |=  url=tape
  ^-  (unit api-operation:web)
  ?:  =("/apps/obelisk/api/run" url)  `%run
  ?:  =("/apps/obelisk/api/parse" url)  `%parse
  ?:  =("/apps/obelisk/api/schema" url)  `%schema
  ?:  =("/apps/obelisk/api/results/save" url)  `%result-save
  ?:  =("/apps/obelisk/api/results/save-text" url)  `%result-text-save
  ~
::
++  make-error
  |=  [code=error-code:web status=@ud message=@t retryable=?]
  ^-  web-error:web
  [code status message retryable ~]
::
++  result-storage-mark
  |=  result-format=result-format:ast
  ^-  @tas
  ?-  result-format
    %csv       %csv
    %html      %html
    %json      %json
    %markdown  %md
    %tab       %tab
    ?(%manx %raw %vector %wain)  %noun
    ?(%spac %tape)  %txt
  ==
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
  ::  Result exports are served locally, so they plan no Obelisk work.
  ::
  |=  request=web-request:web
  ^-  (unit work-plan)
  ?-  -.request
    ?(%result-save %result-text-save)
      ~
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
++  handle-result-save
  ::  A result export.  Obelisk renders the text and urui-files writes
  ::  it under /results, verified like any save.  Parse output arrives
  ::  as text; run results are rendered from the result cache.
  |=  $:  eyre-id=@ta
          request=web-request:web
          state=live-state:web
          =bowl:gall
      ==
  ^-  (quip card live-state:web)
  ?>  ?=(?(%result-save %result-text-save) -.request)
  ::  `path` and `overwrite` sit at different axes in the two requests,
  ::  so each is read after narrowing to one (a fork cannot be found).
  =/  [target=relative-path:web overwrite=?]
    ?-  -.request
      %result-save       [path.request overwrite.request]
      %result-text-save  [path.request overwrite.request]
    ==
  ?.  ?&  ?=(^ target)
          =(%results i.target)
      ==
    :_  state
    %+  respond-error  eyre-id
    (make-error %bad-request 400 'invalid result path' %.n)
  =/  text=(each @t (list card))
    ?:  ?=(%result-text-save -.request)  [%& text.request]
    ?.  =((result-storage-mark format.request) (rear target))
      :-  %|
      %+  respond-error  eyre-id
      (make-error %bad-request 400 'result path mark does not match format' %.n)
    =/  cached=(unit result-cache:web)  result-cache.transient.state
    ?~  cached
      :-  %|
      %+  respond-error  eyre-id
      (make-error %not-found 404 'Query results are no longer available' %.n)
    ?.  =(result-id.request result-id.u.cached)
      :-  %|
      %+  respond-error  eyre-id
      (make-error %not-found 404 'Query results are no longer available' %.n)
    ?:  (gte command-index.request (lent commands.u.cached))
      :-  %|
      %+  respond-error  eyre-id
      (make-error %bad-request 400 'Result command index is out of range' %.n)
    =/  command=cmd-result:ast
      (snag command-index.request commands.u.cached)
    =/  exported=(each @t tang)
      (mule |.((result-export:result-lib format.request command)))
    ?:  ?=(%.y -.exported)  [%& p.exported]
    :-  %|
    %:  respond-error-with
      eyre-id
      :*  %unprocessable
          422
          'Result formatting failed'
          %.n
          (tang-details:result-lib p.exported)
      ==
      ~
    ==
  ?:  ?=(%| -.text)  [p.text state]
  =^  cards  files.transient.state
    %:  write:ufiles
      file-policy:web-lib
      bowl
      eyre-id
      target
      p.text
      overwrite
      files.transient.state
    ==
  [cards state]
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
            %raw
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
      =/  result-id=request-id:web  request-id.job.active
      =.  result-cache.transient.state
        `[result-id commands]
      %:  complete-with-response
        active
        (run-response-with:result-lib result-id commands changed)
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
  ::  the rest are result exports
  [%result-save u.decoded]
::
++  route-http
  |=  [eyre-id=@ta req=inbound-request:eyre our=@p desk=desk now=@da]
  ^-  route-result
  =/  url=tape  (trip url.request.req)
  =/  method=method:http  method.request.req
  =/  operation=(unit api-operation:web)  (api-operation-for url)
  ?^  operation
    (route-api eyre-id req u.operation)
  ::  urui's file wire; urui-files checks method, type, and body itself
  ?:  =("/apps/obelisk/files" url)
    ?.  authenticated.req
      :-  %cards
      %+  respond-error  eyre-id
      (make-error %unauthorized 401 'authentication required' %.n)
    [%files req]
  ?:  =("/apps/obelisk/favicon.ico" url)
    ?.  =(%'GET' method)
      :-  %cards
      %:  respond
        eyre-id
        405
        ~[['content-type' 'text/plain'] ['allow' 'GET']]
        'method not allowed'
      ==
    :-  %cards
    (respond-octs eyre-id 200 ~[['content-type' 'image/x-icon']] favicon)
  =/  route=(unit asset:uhttp)
    ?:  ?|  =("/apps/obelisk" url)
            =("/apps/obelisk/" url)
        ==
      :-  ~
      :-  'text/html; charset=utf-8'
      (as-octs:mimes:html (page:web-lib our))
    (asset-route:uhttp '/apps/obelisk' url.request.req (assets our))
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
  %+  give-simple-payload:app:server  eyre-id
  (respond:uhttp 200 u.route)
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
    %files
      =^  cards  files.transient.state
        %:  handle:ufiles
          file-policy:web-lib
          bowl
          eyre-id
          req.routed
          files.transient.state
        ==
      [cards this]
    %result-save
      =^  cards  state
        (handle-result-save eyre-id request.routed state bowl)
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
  =/  taken=(unit outcome:ufiles)
    %:  take:ufiles
      file-policy:web-lib
      bowl
      wire
      sign-arvo
      files.transient.state
    ==
  ?^  taken
    =.  files.transient.state  next.u.taken
    [cards.u.taken this]
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
  (on-arvo:default wire sign-arvo)
::
++  on-fail  on-fail:default
--
