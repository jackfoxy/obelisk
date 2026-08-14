::  Unit tests for %obelisk-web readiness and active-work transitions.
::
/-  ast=obelisk-ast, web=obelisk-web
/+  readiness=readiness-state, state=obelisk-web, *test
|%
+$  card  card:agent:gall
+$  work-plan  work-plan:readiness
::
++  now
  ^-  @da
  ~2026.8.1
::
++  job
  |=  request-id=request-id:web
  ^-  queued-request:web
  :*  request-id
      `@ta`(cat 3 'request-' (scot %ud request-id))
      now
      [%run %sys 'SELECT 1;']
  ==
::
++  file-job
  |=  request-id=request-id:web
  ^-  queued-request:web
  :*  request-id
      `@ta`(cat 3 'file-' (scot %ud request-id))
      now
      [%file-browse ~]
  ==
::
++  work
  ^-  work-plan
  :*  `action:ast`[%parse %sys "SELECT 1;"]
      %parse
      %parse
      [%none ~]
  ==
::
++  readiness-wire
  |=  request-id=request-id:web
  ^-  wire
  /test/readiness/(scot %ud request-id)
::
++  work-wire
  |=  $:  request-id=request-id:web
          retries=@ud
          stage=@ud
          kind=term
      ==
  ^-  wire
  :~  %test
      %work
      (scot %ud request-id)
      (scot %ud retries)
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
++  work-for
  |=  request=web-request:web
  ^-  (unit work-plan)
  ?-  -.request
    ?(%result-save %file-browse %file-load %file-save %file-delete)  ~
    ?(%run %parse %schema)  `work
  ==
::
++  marker-card
  |=  kind=term
  ^-  card
  (wait-card [~[%test %marker kind] now])
::
++  coordinated-response
  |=  eyre-id=@ta
  ^-  (list card)
  ~[(marker-card %coordinated)]
::
++  unavailable-response
  |=  eyre-id=@ta
  ^-  (list card)
  ~[(marker-card %unavailable)]
::
++  dependencies
  ^-  dependencies:readiness
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
++  controller
  ~(. controller:readiness dependencies)
::
++  active
  |=  [request-id=request-id:web retries=@ud stage=@ud]
  ^-  active-obelisk:web
  =/  job=queued-request:web  (job request-id)
  =/  plan=work-plan  work
  :*  job
      action.plan
      work-kind.plan
      reply-kind.plan
      context.plan
      %watching
      (work-wire request-id retries stage %watch)
      (work-wire request-id retries stage %poke)
      (work-wire request-id retries stage %timeout)
      retries
      stage
  ==
::
++  with-queue
  |=  queue=(list queued-request:web)
  ^-  live-state:web
  =/  state=live-state:web  empty-live-state:state
  =.  queue.transient.state  queue
  state
::
++  with-active
  |=  active=active-obelisk:web
  ^-  live-state:web
  =/  state=live-state:web  empty-live-state:state
  =.  active.transient.state  `active
  state
::
++  with-readiness
  |=  pending=pending-readiness:web
  ^-  live-state:web
  =/  state=live-state:web  empty-live-state:state
  =.  readiness.transient.state  `pending
  state
::
++  test-begin-readiness-00
  =/  first=queued-request:web  (job 1)
  =/  actual=(quip card live-state:web)
    (begin-readiness:controller first empty-live-state:state ~zod)
  =/  expected=live-state:web  empty-live-state:state
  =.  readiness.transient.expected
    `[first 0 (readiness-wire 1)]
  ;:  weld
    (expect-eq !>(~[(watch-card (readiness-wire 1) ~zod)]) !>(-.actual))
    (expect-eq !>(expected) !>(+.actual))
  ==
::
++  test-advance-readiness-01
  =/  first=queued-request:web  (job 1)
  =/  pending=pending-readiness:web
    [first 0 (readiness-wire 1)]
  =/  retried=(quip card live-state:web)
    (advance-readiness:controller pending %.n (with-readiness pending) now ~zod)
  =/  retry-state=live-state:web  empty-live-state:state
  =.  readiness.transient.retry-state
    `[first 1 (readiness-wire 1)]
  =/  ready=(quip card live-state:web)
    (advance-readiness:controller pending %.y (with-readiness pending) now ~zod)
  =/  ready-state=live-state:web  empty-live-state:state
  =.  active.transient.ready-state  `(active 1 0 0)
  =/  exhausted-pending=pending-readiness:web
    [first 2 (readiness-wire 1)]
  =/  exhausted-state=live-state:web  (with-readiness exhausted-pending)
  =.  queue.transient.exhausted-state  ~[(job 2)]
  =/  exhausted=(quip card live-state:web)
    %:  advance-readiness:controller
      exhausted-pending
      %.n
      exhausted-state
      now
      ~zod
    ==
  =/  next-state=live-state:web  empty-live-state:state
  =.  readiness.transient.next-state
    `[(job 2) 0 (readiness-wire 2)]
  ;:  weld
    %+  expect-eq
      !>(~[(wait-card (readiness-wire 1) (add now readiness-delay:state))])
    !>(-.retried)
    (expect-eq !>(retry-state) !>(+.retried))
    %+  expect-eq
      !>  :~  (watch-card (work-wire 1 0 0 %watch) ~zod)
              %+  wait-card
                (work-wire 1 0 0 %timeout)
              (add now work-timeout:state)
          ==
    !>(-.ready)
    (expect-eq !>(ready-state) !>(+.ready))
    %+  expect-eq
      !>  :~  (marker-card %unavailable)
              (watch-card (readiness-wire 2) ~zod)
          ==
    !>(-.exhausted)
    (expect-eq !>(next-state) !>(+.exhausted))
  ==
::
++  test-retry-active-02
  =/  first=active-obelisk:web  (active 1 0 0)
  =/  retried=(quip card live-state:web)
    %:  retry-active:controller
      first
      %.y
      (with-active first)
      now
      ~zod
    ==
  =/  retry-state=live-state:web  empty-live-state:state
  =.  readiness.transient.retry-state
    `[(job 1) 1 (readiness-wire 1)]
  =/  exhausted-active=active-obelisk:web  (active 1 2 0)
  =/  exhausted-state=live-state:web  (with-active exhausted-active)
  =.  queue.transient.exhausted-state  ~[(job 2)]
  =/  exhausted=(quip card live-state:web)
    %:  retry-active:controller
      exhausted-active
      %.y
      exhausted-state
      now
      ~zod
    ==
  =/  next-state=live-state:web  empty-live-state:state
  =.  readiness.transient.next-state
    `[(job 2) 0 (readiness-wire 2)]
  ;:  weld
    %+  expect-eq
      !>  :~  (leave-card (work-wire 1 0 0 %watch) ~zod)
              %+  wait-card
                (readiness-wire 1)
              (add now readiness-delay:state)
          ==
    !>(-.retried)
    (expect-eq !>(retry-state) !>(+.retried))
    %+  expect-eq
      !>  :~  (leave-card (work-wire 1 2 0 %watch) ~zod)
              (marker-card %unavailable)
              (watch-card (readiness-wire 2) ~zod)
          ==
    !>(-.exhausted)
    (expect-eq !>(next-state) !>(+.exhausted))
  ==
::
++  test-start-next-03
  =/  empty=(quip card live-state:web)
    (start-next:controller empty-live-state:state now ~zod)
  =/  expected-empty=(quip card live-state:web)
    [~ empty-live-state:state]
  =/  queued=(quip card live-state:web)
    (start-next:controller (with-queue ~[(job 1) (job 2)]) now ~zod)
  =/  expected=live-state:web  (with-queue ~[(job 2)])
  =.  readiness.transient.expected
    `[(job 1) 0 (readiness-wire 1)]
  ;:  weld
    (expect-eq !>(expected-empty) !>(empty))
    (expect-eq !>(~[(watch-card (readiness-wire 1) ~zod)]) !>(-.queued))
    (expect-eq !>(expected) !>(+.queued))
  ==
::
++  test-start-work-04
  =/  actual=(quip card live-state:web)
    %:  start-work:controller
      (job 1)
      2
      3
      work
      empty-live-state:state
      now
      ~zod
    ==
  =/  expected=live-state:web  empty-live-state:state
  =.  active.transient.expected  `(active 1 2 3)
  ;:  weld
    %+  expect-eq
      !>  :~  (watch-card (work-wire 1 2 3 %watch) ~zod)
              %+  wait-card
                (work-wire 1 2 3 %timeout)
              (add now work-timeout:state)
          ==
    !>(-.actual)
    (expect-eq !>(expected) !>(+.actual))
  ==
::
++  test-start-active-05
  =/  planned=(quip card live-state:web)
    (start-active:controller (job 1) 2 empty-live-state:state now ~zod)
  =/  planned-state=live-state:web  empty-live-state:state
  =.  active.transient.planned-state  `(active 1 2 0)
  =/  local-state=live-state:web  (with-queue ~[(job 2)])
  =/  local=(quip card live-state:web)
    (start-active:controller (file-job 1) 0 local-state now ~zod)
  =/  next-state=live-state:web  empty-live-state:state
  =.  readiness.transient.next-state
    `[(job 2) 0 (readiness-wire 2)]
  ;:  weld
    (expect-eq !>(planned-state) !>(+.planned))
    %+  expect-eq
      !>  :~  (marker-card %coordinated)
              (watch-card (readiness-wire 2) ~zod)
          ==
    !>(-.local)
    (expect-eq !>(next-state) !>(+.local))
  ==
::
++  test-continue-active-06
  =/  first=active-obelisk:web  (active 1 2 0)
  =/  actual=(quip card live-state:web)
    %:  continue-active:controller
      first
      work
      (with-active first)
      now
      ~zod
    ==
  =/  expected=live-state:web  empty-live-state:state
  =.  active.transient.expected  `(active 1 2 1)
  ;:  weld
    %+  expect-eq
      !>  :~  (leave-card (work-wire 1 2 0 %watch) ~zod)
              (watch-card (work-wire 1 2 1 %watch) ~zod)
              %+  wait-card
                (work-wire 1 2 1 %timeout)
              (add now work-timeout:state)
          ==
    !>(-.actual)
    (expect-eq !>(expected) !>(+.actual))
  ==
::
++  test-complete-active-07
  =/  first=active-obelisk:web  (active 1 2 0)
  =/  initial=live-state:web  (with-active first)
  =.  queue.transient.initial  ~[(job 2)]
  =/  response=(list card)  ~[(marker-card %response)]
  =/  actual=(quip card live-state:web)
    %:  complete-active:controller
      first
      response
      %.y
      initial
      now
      ~zod
    ==
  =/  expected=live-state:web  empty-live-state:state
  =.  readiness.transient.expected
    `[(job 2) 0 (readiness-wire 2)]
  ;:  weld
    %+  expect-eq
      !>  :~  (leave-card (work-wire 1 2 0 %watch) ~zod)
              (marker-card %response)
              (watch-card (readiness-wire 2) ~zod)
          ==
    !>(-.actual)
    (expect-eq !>(expected) !>(+.actual))
  ==
--
