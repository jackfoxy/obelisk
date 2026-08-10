::  Readiness and active-work state transitions for %obelisk-web.
::
/-  ast=obelisk-ast, web=obelisk-web
/+  web-lib=obelisk-web
|%
+$  card  card:agent:gall
+$  work-plan
  $:  action=action:ast
      work-kind=obelisk-work-kind:web
      reply-kind=obelisk-reply-kind:web
      context=obelisk-context:web
  ==
+$  dependencies
  $:  readiness-wire=$-(request-id:web wire)
      work-wire=$-([request-id:web @ud @ud term] wire)
      wait-card=$-([wire @da] card)
      watch-card=$-([wire @p] card)
      leave-card=$-([wire @p] card)
      work-for=$-(web-request:web (unit work-plan))
      coordinated-response=$-(@ta (list card))
      unavailable-response=$-(@ta (list card))
  ==
::
++  controller
  |_  =dependencies
  ::
  ++  begin-readiness
    |=  [job=queued-request:web state=live-state:web our=@p]
    ^-  (quip card live-state:web)
    =/  retry-wire=wire  (readiness-wire.dependencies request-id.job)
    =/  pending=pending-readiness:web  [job 0 retry-wire]
    =.  readiness.transient.state  `pending
    :_  state
    ~[(watch-card.dependencies retry-wire our)]
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
        :~  %+  wait-card.dependencies  retry-wire.pending
            (add now readiness-delay:web-lib)
        ==
      %exhausted
        =.  readiness.transient.state  ~
        =/  next=(quip card live-state:web)  (start-next state now our)
        :_  +.next
        (weld (unavailable-response.dependencies eyre-id.job.pending) -.next)
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
    =/  cleanup-cards=(list card)
      ?:  cleanup  ~[(leave-card.dependencies watch-wire.active our)]  ~
    =.  active.transient.state  ~
    ?-  -.decision
      %ready  !!
      %retry
        =/  retry-wire=wire
          (readiness-wire.dependencies request-id.job.active)
        =/  pending=pending-readiness:web
          [job.active failures.decision retry-wire]
        =.  readiness.transient.state  `pending
        :_  state
        %+  weld  cleanup-cards
        :~  %+  wait-card.dependencies  retry-wire
            (add now readiness-delay:web-lib)
        ==
      %exhausted
        =/  next=(quip card live-state:web)  (start-next state now our)
        :_  +.next
        %+  weld  cleanup-cards
        %+  weld  (unavailable-response.dependencies eyre-id.job.active)
        -.next
    ==
  ::
  ++  start-next
    |=  [state=live-state:web now=@da our=@p]
    ^-  (quip card live-state:web)
    ::  Copy the queue out first: testing it in place would narrow +state.
    ::
    =/  queue=(list queued-request:web)  queue.transient.state
    ?~  queue  [~ state]
    =.  queue.transient.state  t.queue
    (begin-readiness i.queue state our)
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
    =/  watch-wire=wire
      (work-wire.dependencies request-id.job retries stage %watch)
    =/  poke-wire=wire
      (work-wire.dependencies request-id.job retries stage %poke)
    =/  timeout-wire=wire
      (work-wire.dependencies request-id.job retries stage %timeout)
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
    :~  (watch-card.dependencies watch-wire our)
        (wait-card.dependencies timeout-wire (add now work-timeout:web-lib))
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
    =/  work=(unit work-plan)  (work-for.dependencies request.job)
    ?~  work
      =^  cards  state  (start-next state now our)
      [(weld (coordinated-response.dependencies eyre-id.job) cards) state]
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
    =^  cards  state
      (start-work job.active retries.active +(stage.active) work state now our)
    [[(leave-card.dependencies watch-wire.active our) cards] state]
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
    =/  cleanup-cards=(list card)
      ?:  cleanup  ~[(leave-card.dependencies watch-wire.active our)]  ~
    =.  active.transient.state  ~
    =/  next=(quip card live-state:web)  (start-next state now our)
    [:(weld cleanup-cards response-cards -.next) +.next]
  --
--
