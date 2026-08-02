::  %obelisk-web: native Sail and HTTP boundary for Obelisk.
::
::  Direct Eyre routing keeps this small desk-local route surface explicit.
::
/-  ast=obelisk-ast, web=obelisk-web
/+  dbug, default-agent, server
/+  file-lib=obelisk-web-file
/+  json-lib=obelisk-web-json, result-lib=obelisk-web-result
/+  schema-lib=obelisk-web-schema
/+  web-lib=obelisk-web
|%
+$  card  card:agent:gall
+$  route-result
  $%  [%cards value=(list card)]
      [%obelisk request=web-request:web]
      [%file request=web-request:web]
  ==
+$  work-plan
  $:  action=action:ast
      work-kind=obelisk-work-kind:web
      reply-kind=obelisk-reply-kind:web
      context=obelisk-context:web
  ==
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
        [%parse default-database.request (trip script.request)]
      `[action %run-parse %parse [%none ~]]
    %parse
      =/  action=action:ast
        [%parse default-database.request (trip script.request)]
      `[action %parse %parse [%none ~]]
    %schema
      =/  action=action:ast
        [%script %sys %vector databases-query:schema-lib]
      `[action %schema %query [%schema-databases default-database.request]]
    %file-browse  ~
    %file-load  ~
    %file-save  ~
  ==
::
++  decode-reply
  |=  [kind=obelisk-reply-kind:web =cage]
  ^-  decoded-reply
  ?.  =(%noun p.cage)  [%malformed ~]
  ?-  kind
    %query
      =/  decoded=(each query-reply tang)
        (mule |.(!<(query-reply q.cage)))
      ?.  ?=(%.y -.decoded)  [%malformed ~]
      [%query p.decoded]
    %parse
      =/  decoded=(each parse-reply tang)
        (mule |.(!<(parse-reply q.cage)))
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
    :~  ['content-type' 'application/json; charset=utf-8']
        ['cache-control' 'no-store']
        ['x-content-type-options' 'nosniff']
    ==
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
++  clay-arch
  |=  beam=path
  ^-  (each arch tang)
  %-  mule  |.
  .^(arch %cy beam)
::
++  clay-physical-paths
  |=  [our=@p desk=desk now=@da clay-path=path]
  ^-  (each (list path) tang)
  =/  beam=path
    (clay-beam:file-lib our desk da+now clay-path)
  =/  loaded=(each arch tang)  (clay-arch beam)
  ?-  -.loaded
    %.n  loaded
    %.y
      =/  here=(list path)
        ?~(fil.p.loaded ~ ~[clay-path])
      =/  names=(list @ta)
        (sort ~(tap in ~(key by dir.p.loaded)) aor)
      =/  children=(each (list path) tang)
        (clay-child-paths our desk now clay-path names)
      ?-  -.children
        %.n  children
        %.y  [%.y (weld here p.children)]
      ==
  ==
::
++  clay-child-paths
  |=  [our=@p desk=desk now=@da parent=path names=(list @ta)]
  ^-  (each (list path) tang)
  ?~  names  [%.y ~]
  =/  child=(each (list path) tang)
    (clay-physical-paths our desk now (snoc parent i.names))
  ?-  -.child
    %.n  child
    %.y
      =/  rest=(each (list path) tang)
        $(names t.names)
      ?-  -.rest
        %.n  rest
        %.y  [%.y (weld p.child p.rest)]
      ==
  ==
::
++  clay-text
  |=  beam=path
  ^-  (each @t tang)
  %-  mule  |.
  (of-wain:format .^(wain %cx beam))
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
  =/  beam=path
    (clay-beam:file-lib our desk da+now clay-path)
  =/  exists=(each ? tang)  (clay-exists beam)
  ?-  -.exists
    %.n  (file-error-cards eyre-id 'Clay browse failed' p.exists)
    %.y
      ?.  p.exists
        (respond-json eyre-id [%file-list ~])
      =/  loaded=(each (list path) tang)
        (clay-physical-paths our desk now clay-path)
      ?-  -.loaded
        %.n  (file-error-cards eyre-id 'Clay browse failed' p.loaded)
        %.y
          =/  entries=(list file-entry-dto:web)
            (entries-from-physical:file-lib relative p.loaded)
          (respond-json eyre-id [%file-list entries])
      ==
  ==
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
  ?-  -.exists
    %.n  (file-error-cards eyre-id 'Clay load failed' p.exists)
    %.y
      ?.  p.exists
        %+  respond-error  eyre-id
        (make-error %not-found 404 'saved file not found' %.n)
      =/  loaded=(each @t tang)  (clay-text beam)
      ?-  -.loaded
        %.n  (file-error-cards eyre-id 'Clay load failed' p.loaded)
        %.y  (respond-json eyre-id [%file relative p.loaded])
      ==
  ==
::
++  file-verify-card
  |=  $:  =wire
          our=@p
          desk=desk
          now=@da
          clay-path=path
      ==
  ^-  card
  :*  %pass  wire  %arvo  %c
      %warp  our  desk  ~  %next  %x  da+now  clay-path
  ==
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
  =/  current=(unit pending-file-save:web)  file-save.transient.state
  ?^  current
    :_  state
    %+  respond-error  eyre-id
    (make-error %unavailable 503 'another file save is pending' %.y)
  =/  clay-path=path  (storage-path:file-lib relative)
  =/  beam=path
    (clay-beam:file-lib our desk da+now clay-path)
  =/  exists=(each ? tang)  (clay-exists beam)
  ?-  -.exists
    %.n
      :_  state
      (file-error-cards eyre-id 'Clay save check failed' p.exists)
    %.y
      %:  save-file-after-check
        eyre-id  relative  content  overwrite  p.exists
        state  our  desk  now
      ==
  ==
::
++  save-file-after-check
  |=  $:  eyre-id=@ta
          relative=relative-path:web
          content=@t
          overwrite=?
          exists=?
          state=live-state:web
          our=@p
          desk=desk
          now=@da
      ==
  ^-  (quip card live-state:web)
  ?:  (save-conflict:file-lib exists overwrite)
    :_  state
    %+  respond-error  eyre-id
    (make-error %conflict 409 'saved file already exists' %.n)
  =/  clay-path=path  (storage-path:file-lib relative)
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
  :~  %:  file-verify-card
          verify-wire  our  desk  now  clay-path
      ==
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
  :*  %unprocessable
      422
      message
      %.n
      (tang-details:result-lib trace)
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
++  start-work
  |=  $:  job=queued-request:web
          retries=@ud
          stage=@ud
          work=work-plan
          state=live-state:web
          now=@da
          our=@p
      ==
  ^-  (quip card live-state:web)
  =/  watch-wire=wire  (work-wire request-id.job retries stage %watch)
  =/  poke-wire=wire  (work-wire request-id.job retries stage %poke)
  =/  timeout-wire=wire  (work-wire request-id.job retries stage %timeout)
  =/  active=active-obelisk:web
    :*  job
        action.work
        work-kind.work
        reply-kind.work
        context.work
        %watching
        watch-wire
        poke-wire
        timeout-wire
        retries
        stage
    ==
  =.  active.transient.state  `active
  :_  state
  :~  (watch-card watch-wire our)
      (wait-card timeout-wire (add now work-timeout:web-lib))
  ==
::
++  start-active
  |=  $:  job=queued-request:web
          retries=@ud
          state=live-state:web
          now=@da
          our=@p
      ==
  ^-  (quip card live-state:web)
  =/  work=(unit work-plan)  (work-for request.job)
  ?~  work
    =/  next=(quip card live-state:web)  (start-next state now our)
    :_  +.next
    (weld (coordinated-response eyre-id.job) -.next)
  (start-work job retries 0 u.work state now our)
::
++  continue-active
  |=  $:  active=active-obelisk:web
          work=work-plan
          state=live-state:web
          now=@da
          our=@p
      ==
  ^-  (quip card live-state:web)
  =/  next=(quip card live-state:web)
    %:  start-work
      job.active
      retries.active
      +(stage.active)
      work
      state
      now
      our
    ==
  :_  +.next
  [(leave-card watch-wire.active our) -.next]
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
++  complete-with-response
  |=  $:  active=active-obelisk:web
          response=web-response:web
          state=live-state:web
          now=@da
          our=@p
      ==
  ^-  (quip card live-state:web)
  %:  complete-active
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
  %:  complete-active
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
  %:  complete-active
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
      (continue-active active work state now our)
    %run-script  (complete-with-malformed active state now our)
    %schema  (complete-with-malformed active state now our)
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
  (continue-active active work state now our)
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
        %none  (complete-with-malformed active state now our)
        %run  (complete-with-malformed active state now our)
      ==
    %run-parse  (complete-with-malformed active state now our)
    %parse  (complete-with-malformed active state now our)
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
      ?-  -.reply.decoded
        %.n
          %:  complete-with-error
            active  %parse  p.reply.decoded  state  now  our
          ==
        %.y
          (handle-parse-success active p.reply.decoded state now our)
      ==
    %query
      ?-  -.reply.decoded
        %.n
          %:  complete-with-error
            active  %query  p.reply.decoded  state  now  our
          ==
        %.y
          (handle-query-success active p.reply.decoded state now our)
      ==
  ==
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
  ?:  (obelisk-backed operation)
    [%obelisk u.decoded]
  [%file u.decoded]
::
++  route-http
  |=  [eyre-id=@ta req=inbound-request:eyre our=@p]
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
    ?-  -.loaded
      %.y  p.loaded
      %.n
        %-  (slog 'obelisk-web state corrupt; using empty state' p.loaded)
        empty-live-state:web-lib
    ==
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
  =/  routed=route-result  (route-http eyre-id req our.bowl)
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
    %file
      =/  handled=(quip card live-state:web)
        %:  handle-file-request
          eyre-id
          request.routed
          state
          our.bowl
          q.byk.bowl
          now.bowl
        ==
      :_  this(state +.handled)
      -.handled
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
        =/  handled=(quip card live-state:web)
          %:  handle-active-fact
            active
            cage.sign
            state
            now.bowl
            our.bowl
          ==
        :_  this(state +.handled)
        -.handled
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
  ?:  =(wire /eyre/connect)
    ?.  ?=([%eyre %bound *] sign-arvo)
      (on-arvo:default wire sign-arvo)
    =.  binding.transient.state
      (binding-after-connect:web-lib accepted.sign-arvo)
    `this(state state)
  =/  pending=(unit pending-file-save:web)  file-save.transient.state
  ?:  ?&  ?=(^ pending)
          =(wire verify-wire.u.pending)
      ==
    =/  completed=(quip card live-state:web)
      (complete-file-save u.pending sign-arvo state)
    :_  this(state +.completed)
    -.completed
  ?:  ?&  ?=(^ pending)
          =(wire timeout-wire.u.pending)
      ==
    ?.  ?=([%behn %wake *] sign-arvo)
      (on-arvo:default wire sign-arvo)
    =/  cancel=card
      (cancel-file-verify-card verify-wire.u.pending our.bowl desk.u.pending)
    =.  file-save.transient.state  ~
    :_  this(state state)
    :-  cancel
    %+  respond-error  eyre-id.u.pending
    (make-error %timeout 504 'Clay save timed out' %.y)
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
  ?:  ?=([%obelisk-web %file-save *] wire)
    `this
  (on-arvo:default wire sign-arvo)
::
++  on-fail  on-fail:default
--
