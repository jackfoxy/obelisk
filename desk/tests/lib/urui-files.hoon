::  Tests for /lib/urui-files.
::
::  Every arm tested here is pure, or refuses before it scries.  The
::  clay reads that feed the planners are exercised by the consumers.
::
/-  urui
/+  *test, ufiles=urui-files
|%
::  +|  Fixtures
::
+$  refusal
  [pol=policy:ufiles req=inbound-request:eyre code=@tas status=@ud]
::
++  script-store
  ^-  store:urui
  :*  name=%script
      noun='Script'
      untitled='script'
      starter=''
      :~  [/scripts ~[%txt] ~ &]
          [/results ~[%csv %json %md %noun] ~ |]
      ==
      preview=`%source
      actions=~[%open %save %save-as]
      refs=&
      share=~
  ==
::
++  files-fixture
  ::  The same store twice: +make-policy must not repeat its roots.
  ^-  files:urui
  ['/apps/probe/files' ~[script-store script-store] ~]
::
++  policy
  ::  Strict, verifying, and reading `noun` files as lines.
  ^-  policy:ufiles
  =/  base=policy:ufiles  (make-policy:ufiles files-fixture /data/probe &)
  base(codecs (snoc codecs.base [%noun %wain]))
::
++  loose
  ::  Knot segments, and answers without waiting for clay.
  ::
  ::  %= on an arm edits the core, not the arm's product, so the
  ::  product is bound first.
  ^-  policy:ufiles
  =/  base=policy:ufiles  policy
  base(strict |, verify |)
::
++  bowl
  ^-  bowl:gall
  %*  .  *bowl:gall
    our  ~zod
    now  ~2026.9.27
    byk  [~zod %probe da+~2026.9.27]
  ==
::
++  id
  ^-  @ta
  (scot %da ~2026.9.27)
::
++  until
  ^-  @da
  (add ~2026.9.27 default-timeout:ufiles)
::
++  saving
  ^-  pending:ufiles
  [~.req id %save /scripts/q1/txt `'select 1' until]
::
++  deleting
  ^-  pending:ufiles
  [~.req id %delete /scripts/q1/txt ~ until]
::
++  post
  ::  An authenticated json POST carrying `body`.
  |=  body=@t
  ^-  inbound-request:eyre
  %*  .  *inbound-request:eyre
    authenticated  &
    request
      :*  %'POST'
          '/apps/probe/files'
          ~[['content-type' 'application/json']]
          `(as-octs:mimes:html body)
      ==
  ==
::
++  accepted
  ::  The op a body parses to under the strict policy.
  |=  body=@t
  ^-  file-op:ufiles
  =/  parsed  (parse-request:ufiles policy (post body))
  ?>  ?=(%& -.parsed)
  p.parsed
::
++  refused
  ::  The failure a request is refused with under `pol`.
  |=  [pol=policy:ufiles req=inbound-request:eyre]
  ^-  failure:ufiles
  =/  parsed  (parse-request:ufiles pol req)
  ?>  ?=(%| -.parsed)
  p.parsed
::
++  writ
  ::  Clay's answer to the verifying %warp.
  |=  held=(unit cage)
  ^-  sign-arvo
  :+  %clay  %writ
  ?~  held  ~
  `[[%x da+~2026.9.27 %probe] /data/probe/scripts/q1/txt u.held]
::
++  wake
  ^-  sign-arvo
  [%behn %wake ~]
::
++  reply-header
  ::  The header of the one http response among `cards`.
  |=  cards=(list card:agent:gall)
  ^-  response-header:http
  =/  found=(list response-header:http)
    %+  murn  cards
    |=  =card:agent:gall
    ^-  (unit response-header:http)
    ?.  ?=([%give %fact * %http-response-header *] card)  ~
    `!<(response-header:http q.cage.p.card)
  ?>  ?=([* ~] found)
  i.found
::
++  reply-status
  |=  cards=(list card:agent:gall)
  ^-  @ud
  status-code:(reply-header cards)
::
++  reply-json
  ::  The json body of the one http response among `cards`.
  |=  cards=(list card:agent:gall)
  ^-  json
  =/  found=(list json)
    %+  murn  cards
    |=  =card:agent:gall
    ^-  (unit json)
    ?.  ?=([%give %fact * %http-response-data *] card)  ~
    =/  data=(unit octs)  !<((unit octs) q.cage.p.card)
    ?~  data  ~
    (de:json:html q.u.data)
  ?>  ?=([* ~] found)
  i.found
::
++  error-code
  ::  The `code` of the error envelope among `cards`.
  |=  cards=(list card:agent:gall)
  ^-  @t
  =/  jon=json  (reply-json cards)
  ?>  ?=([%o *] jon)
  =/  error=json  (~(got by p.jon) 'error')
  ?>  ?=([%o *] error)
  =/  code=json  (~(got by p.error) 'code')
  ?>  ?=([%s *] code)
  p.code
::
::  +|  Policy and paths
::
++  test-make-policy-merges-store-roots
  =/  made=policy:ufiles  (make-policy:ufiles files-fixture /data/probe &)
  ;:  weld
    (expect-eq !>(`path`/data/probe) !>(root.made))
    (expect-eq !>(roots:script-store) !>(roots.made))
    (expect-eq !>(stock-codecs:ufiles) !>(codecs.made))
    (expect !>(strict.made))
    (expect !>(verify.made))
    (expect-eq !>(default-timeout:ufiles) !>(timeout.made))
  ==
::
++  test-valid-segment
  ;:  weld
    (expect !>((valid-segment:ufiles & 'query-1')))
    (expect !>((valid-segment:ufiles | 'query-1')))
    (expect !>(!(valid-segment:ufiles & 'v1.2')))
    (expect !>((valid-segment:ufiles | 'v1.2')))
    (expect !>(!(valid-segment:ufiles & '1st')))
    (expect !>((valid-segment:ufiles | '1st')))
    (expect !>(!(valid-segment:ufiles | '')))
    (expect !>(!(valid-segment:ufiles | '.')))
    (expect !>(!(valid-segment:ufiles | '..')))
    (expect !>(!(valid-segment:ufiles | 'a b')))
    (expect !>(!(valid-segment:ufiles | 'Query')))
  ==
::
++  test-file-codec
  ::  A root admits a path by scope, a name, and its mark; `saving`
  ::  also needs a root the user may save into.
  =/  plain=policy:ufiles  (make-policy:ufiles files-fixture /data/probe &)
  ;:  weld
    (expect !>(=(`%wain (file-codec:ufiles policy /scripts/q1/txt |))))
    (expect !>(=(`%wain (file-codec:ufiles policy /scripts/q1/txt &))))
    (expect !>(=(`%wain (file-codec:ufiles policy /scripts/a/b/txt |))))
    (expect !>(=(`%wain (file-codec:ufiles policy /results/r1/csv |))))
    (expect !>(=(`%json (file-codec:ufiles policy /results/r1/json |))))
    (expect !>(=(`%cord (file-codec:ufiles policy /results/r1/md |))))
    (expect !>(=(`%wain (file-codec:ufiles policy /results/r1/noun |))))
    (expect !>(=(~ (file-codec:ufiles plain /results/r1/noun |))))
    (expect !>(=(~ (file-codec:ufiles policy /results/r1/csv &))))
    (expect !>(=(~ (file-codec:ufiles policy /results/r1/html |))))
    (expect !>(=(~ (file-codec:ufiles policy /scripts/q1/csv |))))
    (expect !>(=(~ (file-codec:ufiles policy /scripts/txt |))))
    (expect !>(=(~ (file-codec:ufiles policy /other/q1/txt |))))
    (expect !>(=(~ (file-codec:ufiles policy ~ |))))
  ==
::
++  test-browse-entries
  ::  Files the policy admits under the scope, each directory between
  ::  them and it, and nothing for the mark leaf's own directory.
  =/  found=(list path)
    :~  /scripts/zeta/txt
        /scripts/nested/beta/txt
        /results/r1/csv
        /results/r2/txt
        /scripts/nested/alpha/txt
        /scripts/ignored/hoon
        /scripts/deep/er/gamma/txt
    ==
  =/  scripts=(list entry:ufiles)
    :~  [/scripts/deep %directory]
        [/scripts/deep/er %directory]
        [/scripts/deep/er/gamma/txt %file]
        [/scripts/nested %directory]
        [/scripts/nested/alpha/txt %file]
        [/scripts/nested/beta/txt %file]
        [/scripts/zeta/txt %file]
    ==
  =/  results=(list entry:ufiles)  ~[[/results/r1/csv %file]]
  ;:  weld
    %+  expect-eq
      !>(scripts)
    !>((browse-entries:ufiles policy /scripts found))
    %+  expect-eq
      !>(results)
    !>((browse-entries:ufiles policy /results found))
  ==
::
::  +|  Codecs
::
++  test-codecs-round-trip
  =/  lines=@t  'first\0a\0asecond ☃\0a'
  =/  tail=@t  'no newline\0aend'
  =/  object=@t  '{"b": 1, "a": [true]}'
  =/  as-lines  (to-cage:ufiles %txt %wain lines)
  =/  as-tail  (to-cage:ufiles %txt %wain tail)
  =/  as-empty  (to-cage:ufiles %txt %wain '')
  =/  as-cord  (to-cage:ufiles %md %cord lines)
  =/  as-json  (to-cage:ufiles %json %json object)
  =/  broken  (to-cage:ufiles %json %json '{]')
  ?>  ?=(%& -.as-lines)
  ?>  ?=(%& -.as-tail)
  ?>  ?=(%& -.as-empty)
  ?>  ?=(%& -.as-cord)
  ?>  ?=(%& -.as-json)
  ;:  weld
    (expect-eq !>(`lines) !>((from-stored:ufiles %wain q.q.p.as-lines)))
    (expect-eq !>(`tail) !>((from-stored:ufiles %wain q.q.p.as-tail)))
    (expect-eq !>(`'') !>((from-stored:ufiles %wain q.q.p.as-empty)))
    (expect-eq !>(`lines) !>((from-stored:ufiles %cord q.q.p.as-cord)))
    (expect !>(=(%md p.p.as-cord)))
    %+  expect-eq
      !>(`(en:json:html (need (de:json:html object))))
    !>((from-stored:ufiles %json q.q.p.as-json))
    (expect !>(?=(%| -.broken)))
    (expect !>(=(~ (from-stored:ufiles %cord [1 2]))))
  ==
::
++  test-text-hash
  (expect-eq !>(`@t`(scot %uv (shax 'abc'))) !>((text-hash:ufiles 'abc')))
::
::  +|  Requests
::
++  test-parse-refuses-bad-requests
  =/  getting=inbound-request:eyre  (post '{}')
  =.  method.request.getting  %'GET'
  =/  plain=inbound-request:eyre  (post '{}')
  =.  header-list.request.plain  ~[['content-type' 'text/plain']]
  =/  empty=inbound-request:eyre  (post '{}')
  =.  body.request.empty  ~
  =/  base=policy:ufiles  policy
  =/  tight=policy:ufiles  base(max-bytes 8)
  =/  cases=(list refusal)
    :~  [policy getting %bad-request 405]
        [policy plain %unsupported-media 415]
        [policy empty %bad-request 400]
        [tight (post '{"op":"load"}') %payload-too-large 413]
        [policy (post 'not json') %bad-request 400]
        [policy (post '[1]') %bad-request 400]
        [policy (post '{"op":"move"}') %bad-request 400]
        [policy (post '{"op":"load"}') %bad-request 400]
        [policy (post '{"op":"load","path":"scripts"}') %bad-request 400]
    ==
  %-  zing
  %+  turn  cases
  |=  =refusal
  =/  got=failure:ufiles  (refused pol.refusal req.refusal)
  ;:  weld
    (expect-eq !>(status.refusal) !>(status.got))
    (expect !>(=(code.refusal code.got)))
  ==
::
++  test-parse-refuses-ill-typed-fields
  =/  bodies=(list @t)
    :~  '{"op":"save","path":["scripts","q1","txt"]}'
        '{"op":"save","path":["scripts","q1","txt"],"text":1}'
        '{"op":"save","path":["scripts","q1","txt"],"text":"a","base":1}'
        '{"op":"save","path":["scripts","q1","txt"],"text":"a","overwrite":1}'
        '{"op":"delete","path":["scripts",1,"txt"]}'
        '{"op":"delete","path":["scripts","q1","txt"],"base":true}'
    ==
  %-  zing
  %+  turn  bodies
  |=  body=@t
  =/  got=failure:ufiles  (refused policy (post body))
  ;:  weld
    (expect-eq !>(400) !>(status.got))
    (expect !>(=(%bad-request code.got)))
  ==
::
++  test-parse-refuses-paths-outside-the-policy
  =/  bodies=(list @t)
    :~  '{"op":"load","path":["scripts","..","q1","txt"]}'
        '{"op":"load","path":["scripts","v1.2","txt"]}'
        '{"op":"load","path":["other","q1","txt"]}'
        '{"op":"load","path":["scripts","q1","csv"]}'
        '{"op":"load","path":["scripts","txt"]}'
        '{"op":"save","path":["results","r1","csv"],"text":"a"}'
        '{"op":"delete","path":["results","r1","html"]}'
        '{"op":"browse","scope":["other"]}'
        '{"op":"browse","scope":[]}'
    ==
  %-  zing
  %+  turn  bodies
  |=  body=@t
  =/  got=failure:ufiles  (refused policy (post body))
  ;:  weld
    (expect-eq !>(400) !>(status.got))
    (expect !>(=(%invalid-path code.got)))
  ==
::
++  test-parse-accepts-each-op
  =/  forced=@t
    %+  rap  3
    :~  '{"op":"save","path":["scripts","q1","txt"],'
        '"text":"x","base":"0vab","overwrite":true}'
    ==
  =/  nulled=@t
    '{"op":"save","path":["scripts","q1","txt"],"text":"x","base":null}'
  ;:  weld
    %+  expect-eq
      !>(`file-op:ufiles`[%browse /scripts/nested])
    !>((accepted '{"op":"browse","scope":["scripts","nested"]}'))
    %+  expect-eq
      !>(`file-op:ufiles`[%browse /results])
    !>((accepted '{"op":"browse","scope":["results"]}'))
    %+  expect-eq
      !>(`file-op:ufiles`[%load /scripts/q1/txt %wain])
    !>((accepted '{"op":"load","path":["scripts","q1","txt"]}'))
    %+  expect-eq
      !>(`file-op:ufiles`[%load /results/r1/json %json])
    !>((accepted '{"op":"load","path":["results","r1","json"]}'))
    %+  expect-eq
      !>(`file-op:ufiles`[%save /scripts/q1/txt %wain 'x' ~ |])
    !>((accepted '{"op":"save","path":["scripts","q1","txt"],"text":"x"}'))
    %+  expect-eq
      !>(`file-op:ufiles`[%save /scripts/q1/txt %wain 'x' ~ |])
    !>((accepted nulled))
    %+  expect-eq
      !>(`file-op:ufiles`[%save /scripts/q1/txt %wain 'x' `'0vab' &])
    !>((accepted forced))
    %+  expect-eq
      !>(`file-op:ufiles`[%delete /results/r1/csv %wain `'0vab'])
    !>((accepted '{"op":"delete","path":["results","r1","csv"],"base":"0vab"}'))
  ==
::
++  test-parse-admits-knots-when-loose
  =/  parsed
    %+  parse-request:ufiles  loose
    (post '{"op":"load","path":["scripts","v1.2","txt"]}')
  ?>  ?=(%& -.parsed)
  %+  expect-eq
    !>(`file-op:ufiles`[%load ~[%scripts ~.v1.2 %txt] %wain])
  !>(p.parsed)
::
++  test-refusals-carry-the-error-envelope
  =/  getting=inbound-request:eyre  (post '{}')
  =.  method.request.getting  %'GET'
  =/  out=outcome:ufiles  (handle:ufiles policy bowl ~.req getting `saving)
  =/  header=response-header:http  (reply-header cards.out)
  =/  expected=json
    %-  pairs:enjs:format
    :~  ['ok' b+|]
        :-  'error'
        %-  pairs:enjs:format
        :~  ['code' s+'bad-request']
            ['message' s+'method not allowed']
            ['retryable' b+|]
            ['details' a+~]
        ==
    ==
  ;:  weld
    (expect-eq !>(405) !>(status-code.header))
    (expect !>(?=(^ (find ~[['allow' 'POST']] headers.header))))
    %-  expect
    !>(?=(^ (find ~[['x-content-type-options' 'nosniff']] headers.header)))
    (expect-eq !>(expected) !>((reply-json cards.out)))
    ::  a refused request leaves the pending change alone
    (expect-eq !>(`saving) !>(next.out))
  ==
::
::  +|  Saves
::
++  test-save-writes-and-waits-for-clay
  =/  out=outcome:ufiles
    %:  plan-save:ufiles
      policy  bowl  ~.req  /scripts/q1/txt  %wain
      'select 1'  ~  |  ~
    ==
  =/  [verify=wire write=wire timeout=wire]  (wires:ufiles id)
  =/  cards=(list card:agent:gall)  cards.out
  ?>  ?=([[%pass *] [%pass *] [%pass *] ~] cards)
  ;:  weld
    (expect !>(?=([%pass * %arvo %c %warp %~zod %probe ~ %next %x *] i.cards)))
    (expect !>(?=([%pass * %arvo %c %info %probe %& [* %ins *] ~] i.t.cards)))
    (expect !>(?=([%pass * %arvo %b %wait *] i.t.t.cards)))
    (expect !>(=(verify p.i.cards)))
    (expect !>(=(write p.i.t.cards)))
    (expect !>(=(timeout p.i.t.t.cards)))
    (expect-eq !>(`saving) !>(next.out))
  ==
::
++  test-save-conflicts
  ::  An existing file needs a matching base or `overwrite`.
  =/  held=@t  'stored'
  =/  attempt
    |=  [base=(unit @t) overwrite=?]
    ^-  outcome:ufiles
    %:  plan-save:ufiles
      policy  bowl  ~.req  /scripts/q1/txt  %wain
      'new text'  base  overwrite  `held
    ==
  =/  exists=outcome:ufiles  (attempt ~ |)
  =/  stale=outcome:ufiles  (attempt `(text-hash:ufiles 'older') |)
  =/  fresh=outcome:ufiles  (attempt `(text-hash:ufiles held) |)
  =/  forced=outcome:ufiles  (attempt `(text-hash:ufiles 'older') &)
  ;:  weld
    (expect-eq !>(409) !>((reply-status cards.exists)))
    (expect-eq !>('exists') !>((error-code cards.exists)))
    (expect !>(=(~ next.exists)))
    (expect-eq !>(409) !>((reply-status cards.stale)))
    (expect-eq !>('changed') !>((error-code cards.stale)))
    (expect !>(?=(^ next.fresh)))
    (expect !>(?=(^ next.forced)))
  ==
::
++  test-save-recreates-a-file-deleted-elsewhere
  =/  out=outcome:ufiles
    %:  plan-save:ufiles
      policy  bowl  ~.req  /scripts/q1/txt  %wain
      'select 1'  `(text-hash:ufiles 'older')  |  ~
    ==
  (expect-eq !>(`saving) !>(next.out))
::
++  test-save-answers-at-once-when-nothing-changes
  =/  hash=@t  (text-hash:ufiles 'same')
  =/  out=outcome:ufiles
    %:  plan-save:ufiles
      policy  bowl  ~.req  /scripts/q1/txt  %wain
      'same'  `hash  |  `'same'
    ==
  =/  expected=json  (pairs:enjs:format ~[['ok' b+&] ['hash' s+hash]])
  ;:  weld
    (expect-eq !>(200) !>((reply-status cards.out)))
    (expect-eq !>(expected) !>((reply-json cards.out)))
    (expect !>(=(~ next.out)))
    (expect !>(=(~ (skim cards.out |=(=card:agent:gall ?=(%pass -.card))))))
  ==
::
++  test-save-refuses-content-the-mark-cannot-hold
  =/  out=outcome:ufiles
    %:  plan-save:ufiles
      policy  bowl  ~.req  /results/r1/json  %json
      '{]'  ~  |  ~
    ==
  ;:  weld
    (expect-eq !>(422) !>((reply-status cards.out)))
    (expect-eq !>('unprocessable') !>((error-code cards.out)))
    (expect !>(=(~ next.out)))
  ==
::
++  test-save-without-verify-answers-with-the-write
  =/  out=outcome:ufiles
    %:  plan-save:ufiles
      loose  bowl  ~.req  /scripts/q1/txt  %wain
      'select 1'  ~  |  ~
    ==
  ?>  ?=([* *] cards.out)
  ;:  weld
    (expect !>(?=([%pass * %arvo %c %info *] i.cards.out)))
    (expect-eq !>(200) !>((reply-status cards.out)))
    (expect !>(=(~ next.out)))
  ==
::
++  test-changes-refuse-while-one-is-pending
  =/  saved=outcome:ufiles
    %:  save:ufiles
      policy  bowl  ~.req  /scripts/q1/txt  %wain
      'x'  ~  |  `saving
    ==
  =/  removed=outcome:ufiles
    (remove:ufiles policy bowl ~.req /scripts/q1/txt %wain ~ `saving)
  ;:  weld
    (expect-eq !>(503) !>((reply-status cards.saved)))
    (expect-eq !>('unavailable') !>((error-code cards.saved)))
    (expect-eq !>(`saving) !>(next.saved))
    (expect-eq !>(503) !>((reply-status cards.removed)))
    (expect-eq !>(`saving) !>(next.removed))
  ==
::
++  test-write-refuses-paths-outside-the-policy
  =/  cases=(list path)
    :~  /other/r1/csv
        /results/r1/html
        ~[%results ~.v1.2 %csv]
    ==
  %-  zing
  %+  turn  cases
  |=  rel=path
  =/  out=outcome:ufiles  (write:ufiles policy bowl ~.req rel 'x' | ~)
  ;:  weld
    (expect-eq !>(400) !>((reply-status cards.out)))
    (expect-eq !>('invalid-path') !>((error-code cards.out)))
  ==
::
::  +|  Deletes
::
++  test-delete-plans
  =/  held=@t  'stored'
  =/  gone=outcome:ufiles
    (plan-delete:ufiles policy bowl ~.req /scripts/q1/txt ~ ~)
  =/  stale=outcome:ufiles
    %:  plan-delete:ufiles
      policy  bowl  ~.req  /scripts/q1/txt
      `(text-hash:ufiles 'older')  `held
    ==
  =/  done=outcome:ufiles
    %:  plan-delete:ufiles
      policy  bowl  ~.req  /scripts/q1/txt
      `(text-hash:ufiles held)  `held
    ==
  =/  quick=outcome:ufiles
    (plan-delete:ufiles loose bowl ~.req /scripts/q1/txt ~ `held)
  =/  cards=(list card:agent:gall)  cards.done
  ?>  ?=([* * * ~] cards)
  ;:  weld
    (expect-eq !>(404) !>((reply-status cards.gone)))
    (expect-eq !>('not-found') !>((error-code cards.gone)))
    (expect-eq !>(409) !>((reply-status cards.stale)))
    (expect-eq !>('changed') !>((error-code cards.stale)))
    (expect !>(?=([%pass * %arvo %c %warp *] i.cards)))
    (expect !>(?=([%pass * %arvo %c %info %probe %& [* %del ~] ~] i.t.cards)))
    (expect !>(?=([%pass * %arvo %b %wait *] i.t.t.cards)))
    (expect-eq !>(`deleting) !>(next.done))
    (expect-eq !>(200) !>((reply-status cards.quick)))
    (expect !>(=(~ next.quick)))
  ==
::
::  +|  Signs
::
++  test-take-ignores-other-wires-and-stale-changes
  =/  [verify=wire write=wire timeout=wire]  (wires:ufiles id)
  =/  old=wire  timeout:(wires:ufiles ~.older)
  ;:  weld
    (expect !>(=(~ (take:ufiles policy bowl /other/wire wake `saving))))
    %+  expect-eq
      !>(`(unit outcome:ufiles)``[~ ~])
    !>((take:ufiles policy bowl timeout wake ~))
    %+  expect-eq
      !>(`(unit outcome:ufiles)``[~ `saving])
    !>((take:ufiles policy bowl old wake `saving))
    %+  expect-eq
      !>(`(unit outcome:ufiles)``[~ `saving])
    !>((take:ufiles policy bowl verify wake `saving))
  ==
::
++  test-take-times-out
  =/  [verify=wire write=wire timeout=wire]  (wires:ufiles id)
  =/  out=outcome:ufiles
    (need (take:ufiles policy bowl timeout wake `saving))
  =/  cards=(list card:agent:gall)  cards.out
  ?>  ?=([[%pass *] * * * ~] cards)
  ;:  weld
    (expect !>(?=([%pass * %arvo %c %warp %~zod %probe ~] i.cards)))
    (expect !>(=(verify p.i.cards)))
    (expect-eq !>(504) !>((reply-status cards)))
    (expect-eq !>('timeout') !>((error-code cards)))
    (expect !>(=(~ next.out)))
  ==
::
++  test-take-confirms-a-verified-save
  =/  [verify=wire write=wire timeout=wire]  (wires:ufiles id)
  =/  stored=cage  [%txt !>((storage-wain:ufiles 'select 1'))]
  =/  other=cage  [%txt !>((storage-wain:ufiles 'select 2'))]
  =/  good=outcome:ufiles
    (need (take:ufiles policy bowl verify (writ `stored) `saving))
  =/  bad=outcome:ufiles
    (need (take:ufiles policy bowl verify (writ `other) `saving))
  =/  lost=outcome:ufiles
    (need (take:ufiles policy bowl verify (writ ~) `saving))
  =/  hash=@t  (text-hash:ufiles 'select 1')
  =/  expected=json  (pairs:enjs:format ~[['ok' b+&] ['hash' s+hash]])
  =/  cards=(list card:agent:gall)  cards.good
  ?>  ?=([[%pass *] *] cards)
  ;:  weld
    (expect !>(?=([%pass * %arvo %b %rest *] i.cards)))
    (expect !>(=(timeout p.i.cards)))
    (expect-eq !>(200) !>((reply-status cards)))
    (expect-eq !>(expected) !>((reply-json cards)))
    (expect !>(=(~ next.good)))
    (expect-eq !>(500) !>((reply-status cards.bad)))
    (expect-eq !>('internal') !>((error-code cards.bad)))
    (expect !>(=(~ next.bad)))
    (expect-eq !>(500) !>((reply-status cards.lost)))
  ==
::
++  test-take-confirms-a-verified-delete
  =/  [verify=wire write=wire timeout=wire]  (wires:ufiles id)
  =/  stored=cage  [%txt !>((storage-wain:ufiles 'select 1'))]
  =/  good=outcome:ufiles
    (need (take:ufiles policy bowl verify (writ ~) `deleting))
  =/  bad=outcome:ufiles
    (need (take:ufiles policy bowl verify (writ `stored) `deleting))
  =/  expected=json  (pairs:enjs:format ~[['ok' b+&]])
  ;:  weld
    (expect-eq !>(200) !>((reply-status cards.good)))
    (expect-eq !>(expected) !>((reply-json cards.good)))
    (expect !>(=(~ next.good)))
    (expect-eq !>(500) !>((reply-status cards.bad)))
  ==
--
