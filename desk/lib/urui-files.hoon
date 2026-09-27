::  urui-files: the server half of the urui file wire.
::
::  An agent serves one POST route with +handle and forwards every sign
::  on a /urui-files wire to +take.  A save or delete is single-flight;
::  with `verify` it is answered only after clay confirms the change.
::
::  Authentication is the agent's, and comes before +handle.  Only
::  +handle, +write, +save, and +remove scry; every decision is made
::  by a pure arm they feed, so the tests need no ship.
::
/-  urui
/+  uhttp=urui-http
|%
::  +|  Types
::
+$  codec  ?(%wain %cord %json)
::
+$  policy
  ::  Where an app's files live and what may be done with them.
  ::
  ::  `strict` limits path segments to @tas.  `max-bytes` bounds the
  ::  request body.
  $:  root=path
      roots=(list root:urui)
      codecs=(list [mark=@tas =codec])
      strict=?
      verify=?
      timeout=@dr
      max-bytes=@ud
  ==
::
+$  pending
  ::  The one save or delete awaiting clay.  `expect` is the text a
  ::  verified save must read back; `until` is when it times out.
  $:  eyre-id=@ta
      id=@ta
      op=?(%save %delete)
      rel=path
      expect=(unit @t)
      until=@da
  ==
::
+$  file-op
  ::  A validated request.
  $%  [%browse scope=path]
      [%load rel=path =codec]
      [%save rel=path =codec text=@t base=(unit @t) overwrite=?]
      [%delete rel=path =codec base=(unit @t)]
  ==
::
+$  failure
  $:  code=@tas
      status=@ud
      message=@t
      retryable=?
      details=(list @t)
  ==
::
+$  entry  [rel=path kind=?(%file %directory)]
::
+$  outcome  [cards=(list card:agent:gall) next=(unit pending)]
::
::  +|  Constants
::
++  stock-codecs
  ^-  (list [mark=@tas =codec])
  :~  [%txt %wain]
      [%csv %wain]
      [%tab %wain]
      [%md %cord]
      [%html %cord]
      [%svg %cord]
      [%json %json]
  ==
::
++  default-timeout  ~s10
::
++  default-max-bytes  1.048.576
::
++  busy
  ^-  failure
  [%unavailable 503 'another file change is pending' & ~]
::
++  changed
  ^-  failure
  [%changed 409 'file changed since it was loaded' | ~]
::
++  missing
  ^-  failure
  [%not-found 404 'file not found' | ~]
::
::  +|  Public API
::
++  make-policy
  ::  The policy for one app's stores, with the stock codecs.
  ::
  ::  `strict` limits segments to @tas.  Adjust the product for the
  ::  rest, e.g. an extra codec:
  ::    =/  base  (make-policy files /data/obelisk &)
  ::    base(codecs (snoc codecs.base [%noun %wain]))
  |=  [=files:urui root=path strict=?]
  ^-  policy
  =/  roots=(list root:urui)
    %+  roll  stores.files
    |=  [=store:urui kept=(list root:urui)]
    ^-  (list root:urui)
    =/  fresh=(list root:urui)
      (skip roots.store |=(item=root:urui ?=(^ (find ~[item] kept))))
    (weld kept fresh)
  [root roots stock-codecs strict & default-timeout default-max-bytes]
::
++  handle
  ::  One request on the file route: the cards answering it, and the
  ::  pending change it starts.
  ::
  ::  Example, in the agent's POST branch after its auth check:
  ::    =^  cards  files  (handle:ufiles policy bowl eyre-id req files)
  |=  $:  =policy
          =bowl:gall
          eyre-id=@ta
          req=inbound-request:eyre
          current=(unit pending)
      ==
  ^-  outcome
  =/  parsed=(each file-op failure)  (parse-request policy req)
  ?:  ?=(%| -.parsed)  [(refuse eyre-id p.parsed) current]
  =/  op=file-op  p.parsed
  ?-  -.op
      %browse
    =/  found=(each (list path) tang)
      (mule |.((browse-paths policy bowl scope.op)))
    :_  current
    ?:  ?=(%| -.found)
      %+  refuse  eyre-id
      (fail-with %internal 500 'clay browse failed' p.found)
    %+  reply  eyre-id
    %-  ok-json
    :~  :-  'entries'
        :-  %a
        %+  turn  (browse-entries policy scope.op p.found)
        |=  =entry
        %-  pairs:enjs:format
        :~  ['path' a+(turn rel.entry |=(seg=@ta s+seg))]
            ['kind' s+kind.entry]
        ==
    ==
  ::
      %load
    =/  held=(each (unit @t) tang)  (stored policy bowl rel.op codec.op)
    :_  current
    ?:  ?=(%| -.held)
      %+  refuse  eyre-id
      (fail-with %internal 500 'clay load failed' p.held)
    ?~  p.held  (refuse eyre-id missing)
    %+  reply  eyre-id
    (ok-json ~[['text' s+u.p.held] ['hash' s+(text-hash u.p.held)]])
  ::
      %save
    %:  save
      policy  bowl  eyre-id  rel.op  codec.op
      text.op  base.op  overwrite.op  current
    ==
  ::
      %delete
    (remove policy bowl eyre-id rel.op codec.op base.op current)
  ==
::
++  write
  ::  A save the app computed itself, such as an exported result set:
  ::  checked, answered and verified exactly like a %save request, and
  ::  allowed into roots with `save=|`.
  ::
  ::  Example, after the app's own checks:
  ::    =^  cards  files
  ::      (write:ufiles policy bowl eyre-id rel text overwrite files)
  |=  $:  =policy
          =bowl:gall
          eyre-id=@ta
          rel=path
          text=@t
          overwrite=?
          current=(unit pending)
      ==
  ^-  outcome
  =/  found=(unit codec)
    ?.  (levy rel |=(seg=@ta (valid-segment strict.policy seg)))  ~
    (file-codec policy rel |)
  ?~  found
    [(refuse eyre-id (fail %invalid-path 400 'invalid file path')) current]
  (save policy bowl eyre-id rel u.found text ~ overwrite current)
::
++  take
  ::  A clay or behn sign on a /urui-files wire; ~ for any other wire.
  ::
  ::  A sign for a change that is no longer pending is ignored.
  ::
  ::  Example, in the agent's +on-arvo:
  ::    =/  taken  (take:ufiles policy bowl wire sign-arvo files)
  ::    ?^  taken
  ::      =.  files  next.u.taken
  ::      [cards.u.taken this]
  |=  $:  =policy
          =bowl:gall
          =wire
          =sign-arvo
          current=(unit pending)
      ==
  ^-  (unit outcome)
  ?.  ?=([%urui-files @ @ ~] wire)  ~
  =/  job=(unit pending)  current
  ?~  job  `[~ current]
  ?.  =(i.t.wire id.u.job)  `[~ current]
  =/  [verify=^wire write=^wire timeout=^wire]  (wires id.u.job)
  ?:  =(%timeout i.t.t.wire)
    ?.  ?=([%behn %wake *] sign-arvo)  `[~ current]
    =/  cancel=card:agent:gall
      [%pass verify %arvo %c %warp our.bowl q.byk.bowl ~]
    =/  late=failure  [%timeout 504 'clay did not confirm the change' & ~]
    `[[cancel (refuse eyre-id.u.job late)] ~]
  ?.  =(%verify i.t.t.wire)  `[~ current]
  ?.  ?=([%clay %writ *] sign-arvo)  `[~ current]
  =/  =riot:clay  +.+.sign-arvo
  =/  rest=card:agent:gall  [%pass timeout %arvo %b %rest until.u.job]
  :-  ~
  :_  ~
  :-  rest
  ?-  op.u.job
      %delete
    ?~  riot  (reply eyre-id.u.job (ok-json ~))
    %+  refuse  eyre-id.u.job
    (fail %internal 500 'clay delete verification failed')
  ::
      %save
    =/  read=(unit @t)
      ?~  riot  ~
      =/  found=(unit codec)  (file-codec policy rel.u.job |)
      ?~  found  ~
      (from-stored u.found q.q.r.u.riot)
    ?:  &(?=(^ read) =(read expect.u.job))
      (reply eyre-id.u.job (ok-json ~[['hash' s+(text-hash u.read)]]))
    %+  refuse  eyre-id.u.job
    (fail %internal 500 'clay save verification failed')
  ==
::
::  +|  Changes
::
++  save
  ::  A save of `text` at `rel`, after reading what clay holds there.
  |=  $:  =policy
          =bowl:gall
          eyre-id=@ta
          rel=path
          =codec
          text=@t
          base=(unit @t)
          overwrite=?
          current=(unit pending)
      ==
  ^-  outcome
  ?^  current  [(refuse eyre-id busy) current]
  =/  held=(each (unit @t) tang)  (stored policy bowl rel codec)
  ?:  ?=(%| -.held)
    :_  current
    %+  refuse  eyre-id
    (fail-with %internal 500 'clay save check failed' p.held)
  (plan-save policy bowl eyre-id rel codec text base overwrite p.held)
::
++  remove
  ::  A delete at `rel`, after reading what clay holds there.
  |=  $:  =policy
          =bowl:gall
          eyre-id=@ta
          rel=path
          =codec
          base=(unit @t)
          current=(unit pending)
      ==
  ^-  outcome
  ?^  current  [(refuse eyre-id busy) current]
  =/  held=(each (unit @t) tang)  (stored policy bowl rel codec)
  ?:  ?=(%| -.held)
    :_  current
    %+  refuse  eyre-id
    (fail-with %internal 500 'clay delete check failed' p.held)
  (plan-delete policy bowl eyre-id rel base p.held)
::
++  plan-save
  ::  A save of `text` at `rel`, given what clay holds there now.
  ::
  ::  An existing file needs `overwrite`, or a `base` matching its hash;
  ::  a missing one is written whatever `base` says.  Text that would
  ::  read back as what is already stored is answered at once: clay
  ::  would see no change, and a verifying %warp would wait forever.
  |=  $:  =policy
          =bowl:gall
          eyre-id=@ta
          rel=path
          =codec
          text=@t
          base=(unit @t)
          overwrite=?
          held=(unit @t)
      ==
  ^-  outcome
  =/  encoded=(each cage tang)  (to-cage (@tas (rear rel)) codec text)
  ?:  ?=(%| -.encoded)
    :_  ~
    %+  refuse  eyre-id
    %:  fail-with
      %unprocessable
      422
      'file content does not match its format'
      p.encoded
    ==
  =/  expect=@t
    ~|  "round trip failed for {(spud rel)}"
        (need (from-stored codec q.q.p.encoded))
  =/  conflict=(unit failure)
    ?~  held  ~
    ?:  overwrite  ~
    ?~  base  `(fail %exists 409 'file already exists')
    ?:  =(u.base (text-hash u.held))  ~
    `changed
  ?^  conflict  [(refuse eyre-id u.conflict) ~]
  =/  done=(list card:agent:gall)
    (reply eyre-id (ok-json ~[['hash' s+(text-hash expect)]]))
  ?:  =(held `expect)  [done ~]
  =/  id=@ta  (scot %da now.bowl)
  =/  until=@da  (add now.bowl timeout.policy)
  =/  cards=(list card:agent:gall)
    (change-cards policy bowl id until rel [%ins p.encoded])
  ?.  verify.policy  [(weld cards done) ~]
  [cards `[eyre-id id %save rel `expect until]]
::
++  plan-delete
  ::  A delete at `rel`, given what clay holds there now.
  |=  $:  =policy
          =bowl:gall
          eyre-id=@ta
          rel=path
          base=(unit @t)
          held=(unit @t)
      ==
  ^-  outcome
  ?~  held  [(refuse eyre-id missing) ~]
  ?:  &(?=(^ base) !=(u.base (text-hash u.held)))
    [(refuse eyre-id changed) ~]
  =/  id=@ta  (scot %da now.bowl)
  =/  until=@da  (add now.bowl timeout.policy)
  =/  cards=(list card:agent:gall)
    (change-cards policy bowl id until rel [%del ~])
  ?.  verify.policy  [(weld cards (reply eyre-id (ok-json ~))) ~]
  [cards `[eyre-id id %delete rel ~ until]]
::
++  change-cards
  ::  The %info for a change and, when verifying, the %warp that
  ::  watches for it and the %wait that bounds it.  The %warp goes
  ::  first, so it is in place before the change lands.
  |=  [=policy =bowl:gall id=@ta until=@da rel=path =miso:clay]
  ^-  (list card:agent:gall)
  =/  clay-path=path  (weld root.policy rel)
  =/  [verify=wire write=wire timeout=wire]  (wires id)
  =/  info=card:agent:gall
    [%pass write %arvo %c %info q.byk.bowl %& ~[[clay-path miso]]]
  ?.  verify.policy  ~[info]
  :~  :*  %pass  verify  %arvo  %c  %warp  our.bowl  q.byk.bowl
          ~  %next  %x  da+now.bowl  clay-path
      ==
      info
      [%pass timeout %arvo %b %wait until]
  ==
::
++  wires
  ::  The verify, write, and timeout wires of change `id`.
  |=  id=@ta
  ^-  [verify=wire write=wire timeout=wire]
  [/urui-files/[id]/verify /urui-files/[id]/write /urui-files/[id]/timeout]
::
::  +|  Requests
::
++  parse-request
  ::  The request on the file route, validated, or why it is refused.
  |=  [=policy req=inbound-request:eyre]
  ^-  (each file-op failure)
  =/  raw=request:http  request.req
  ?.  =(%'POST' method.raw)
    [%| (fail %bad-request 405 'method not allowed')]
  ?.  (json-type header-list.raw)
    :-  %|
    (fail %unsupported-media 415 'content-type must be application/json')
  ?~  body.raw  [%| (fail %bad-request 400 'missing JSON body')]
  ?:  (gth p.u.body.raw max-bytes.policy)
    [%| (fail %payload-too-large 413 'request body is too large')]
  =/  jon=(unit json)  (de:json:html q.u.body.raw)
  ?.  ?=([~ %o *] jon)
    [%| (fail %bad-request 400 'malformed JSON request')]
  =/  fields=(map @t json)  p.u.jon
  =/  bad=failure  (fail %bad-request 400 'missing or ill-typed field')
  =/  invalid=failure  (fail %invalid-path 400 'invalid file path')
  =/  op=(unit @t)  (text-field fields 'op')
  ?+  op  [%| (fail %bad-request 400 'unknown op')]
      [~ %browse]
    =/  scope=(unit (unit path))  (path-field policy fields 'scope')
    ?~  scope  [%| bad]
    ?~  u.scope  [%| invalid]
    ?.  %+  lien  roots.policy
        |=(item=root:urui =(scope.item (scag (lent scope.item) u.u.scope)))
      [%| invalid]
    [%& %browse u.u.scope]
  ::
      [~ %load]
    =/  rel=(unit (unit path))  (path-field policy fields 'path')
    ?~  rel  [%| bad]
    ?~  u.rel  [%| invalid]
    =/  found=(unit codec)  (file-codec policy u.u.rel |)
    ?~  found  [%| invalid]
    [%& %load u.u.rel u.found]
  ::
      [~ %save]
    =/  rel=(unit (unit path))  (path-field policy fields 'path')
    =/  text=(unit @t)  (text-field fields 'text')
    =/  base=(unit (unit @t))  (base-field fields)
    =/  overwrite=(unit ?)
      =/  value=(unit json)  (~(get by fields) 'overwrite')
      ?~  value  `|
      ?.  ?=([%b *] u.value)  ~
      `p.u.value
    ?~  rel  [%| bad]
    ?~  text  [%| bad]
    ?~  base  [%| bad]
    ?~  overwrite  [%| bad]
    ?~  u.rel  [%| invalid]
    =/  found=(unit codec)  (file-codec policy u.u.rel &)
    ?~  found  [%| invalid]
    [%& %save u.u.rel u.found u.text u.base u.overwrite]
  ::
      [~ %delete]
    =/  rel=(unit (unit path))  (path-field policy fields 'path')
    =/  base=(unit (unit @t))  (base-field fields)
    ?~  rel  [%| bad]
    ?~  base  [%| bad]
    ?~  u.rel  [%| invalid]
    =/  found=(unit codec)  (file-codec policy u.u.rel |)
    ?~  found  [%| invalid]
    [%& %delete u.u.rel u.found u.base]
  ==
::
++  json-type
  ::  Does the request declare a json body?
  |=  headers=header-list:http
  ^-  ?
  =/  value=(unit @t)  (get-header:http 'content-type' headers)
  ?~  value  |
  =/  normal=@t  (crip (cass (trip u.value)))
  ?|  =('application/json' normal)
      =('application/json; charset=utf-8' normal)
  ==
::
++  text-field
  |=  [fields=(map @t json) key=@t]
  ^-  (unit @t)
  =/  value=(unit json)  (~(get by fields) key)
  ?.  ?=([~ %s *] value)  ~
  `p.u.value
::
++  base-field
  ::  `base`: absent or null is no base, a string is one, else ~.
  |=  fields=(map @t json)
  ^-  (unit (unit @t))
  =/  value=(unit json)  (~(get by fields) 'base')
  ?:  ?=(?(~ [~ ~]) value)  `~
  ?.  ?=([~ %s *] value)  ~
  ``p.u.value
::
++  path-field
  ::  A json array of path segments: ~ if absent or not an array of
  ::  strings, `~ if a segment is invalid under the policy.
  |=  [=policy fields=(map @t json) key=@t]
  ^-  (unit (unit path))
  =/  value=(unit json)  (~(get by fields) key)
  ?.  ?=([~ %a *] value)  ~
  ?.  (levy p.u.value |=(item=json ?=([%s *] item)))  ~
  =/  parts=(list @ta)
    %+  murn  p.u.value
    |=  item=json
    ^-  (unit @ta)
    ?.  ?=([%s *] item)  ~
    ?.  (valid-segment strict.policy p.item)  ~
    `(@ta p.item)
  ?.  =((lent parts) (lent p.u.value))  `~
  ``parts
::
::  +|  Paths
::
++  valid-segment
  ::  A knot, or a @tas under `strict`, and never . or ..
  |=  [strict=? seg=@t]
  ^-  ?
  ?&  !=('' seg)
      !=('.' seg)
      !=('..' seg)
      ?:(strict ((sane %tas) seg) ((sane %ta) seg))
  ==
::
++  file-codec
  ::  The codec for a file path the policy admits, or ~.
  ::
  ::  A path lies in a root when the root's scope prefixes it, at least
  ::  one name segment follows, and its last segment is one of the
  ::  root's marks.  `saving` asks for a root with `save=&`.
  |=  [=policy rel=path saving=?]
  ^-  (unit codec)
  ::  =(~ rel), not ?~: ?~ would narrow `rel` to a non-empty list, and
  ::  +scag's product, cast ^+ to its list, then cannot be ~ (nest-fail).
  ?:  =(~ rel)  ~
  =/  mark=@ta  (rear rel)
  ?.  %+  lien  roots.policy
      |=  item=root:urui
      ?&  (gth (lent rel) +((lent scope.item)))
          =(scope.item (scag (lent scope.item) rel))
          ?=(^ (find ~[mark] marks.item))
          |(!saving save.item)
      ==
    ~
  =/  found=(list [mark=@tas =codec])
    (skim codecs.policy |=([name=@tas =codec] =(name mark)))
  ?~(found ~ `codec.i.found)
::
++  browse-entries
  ::  The admitted files under `scope`, with each directory between
  ::  them and it, sorted by path text.
  ::
  ::  A file's last segment is its mark and the one before is its name,
  ::  so its directories are its prefixes shorter than the name.
  |=  [=policy scope=path found=(list path)]
  ^-  (list entry)
  =/  files=(list path)
    %+  skim  found
    |=  rel=path
    ?&  =(scope (scag (lent scope) rel))
        ?=(^ (file-codec policy rel |))
    ==
  ::  Each wet-gate product is bound to a typed face before the next
  ::  wet gate sees it; chained inline, the mull loops (fuse-loop).
  =/  dirs=(set path)
    %+  roll  files
    |=  [rel=path seen=(set path)]
    ^-  (set path)
    =/  low=@ud  +((lent scope))
    =/  high=@ud  (sub (lent rel) 2)
    ?:  (gth low high)  seen
    =/  more=(list path)
      (turn (gulf low high) |=(n=@ud `path`(scag n rel)))
    (~(gas in seen) more)
  =/  folders=(list entry)
    (turn ~(tap in dirs) |=(rel=path `entry`[rel %directory]))
  =/  leaves=(list entry)
    (turn files |=(rel=path `entry`[rel %file]))
  %+  sort  (weld folders leaves)
  |=([a=entry b=entry] (aor (spat rel.a) (spat rel.b)))
::
::  +|  Codecs
::
++  to-cage
  ::  `text` as the noun `mark` stores, or why it will not convert.
  |=  [mark=@tas =codec text=@t]
  ^-  (each cage tang)
  %-  mule  |.
  ^-  cage
  ?-  codec
    %wain  [mark !>((storage-wain text))]
    %cord  [mark !>(text)]
    %json  [mark !>((need (de:json:html text)))]
  ==
::
++  from-stored
  ::  The text a stored noun reads as under `codec`; ~ if it does not.
  |=  [=codec stored=*]
  ^-  (unit @t)
  =/  decoded=(each @t tang)
    %-  mule  |.
    ?-  codec
      %wain  (of-wain:format ;;(wain stored))
      %cord  ;;(@t stored)
      %json  (en:json:html ;;(json stored))
    ==
  ?:(?=(%| -.decoded) ~ `p.decoded)
::
++  storage-wain
  ::  Lines for a wain mark.  +to-wain drops the empty line after a
  ::  final newline, so it is put back, and the text round-trips.
  |=  text=@t
  ^-  wain
  =/  lines=wain  (to-wain:format text)
  ?:  =(0 text)  lines
  =/  size=@ud  (met 3 text)
  ?.  =(10 (cut 3 [(dec size) 1] text))  lines
  (snoc lines '')
::
++  text-hash
  ::  The version token of a file's text: what +load answers as `hash`
  ::  and what a later request sends back as `base`.
  |=  text=@t
  ^-  @t
  (scot %uv (shax text))
::
::  +|  Responses
::
++  fail
  ::  A refusal the client should not retry.
  |=  [code=@tas status=@ud message=@t]
  ^-  failure
  [code status message | ~]
::
++  fail-with
  ::  A server-side failure, carrying its trace as details.
  |=  [code=@tas status=@ud message=@t trace=tang]
  ^-  failure
  [code status message | (turn trace |=(=tank (crip ~(ram re tank))))]
::
++  ok-json
  |=  fields=(list [@t json])
  ^-  json
  (pairs:enjs:format [['ok' b+&] fields])
::
++  json-headers
  ^-  header-list:http
  :~  ['content-type' 'application/json; charset=utf-8']
      ['cache-control' 'no-store']
      ['x-content-type-options' 'nosniff']
  ==
::
++  reply
  ::  A 200 answer with a json body.
  |=  [eyre-id=@ta =json]
  ^-  (list card:agent:gall)
  (answer eyre-id 200 json-headers json)
::
++  refuse
  ::  The failure's status and error envelope.  A 405 also names the
  ::  allowed method.
  |=  [eyre-id=@ta =failure]
  ^-  (list card:agent:gall)
  =/  headers=header-list:http
    ?.  =(405 status.failure)  json-headers
    (snoc json-headers ['allow' 'POST'])
  =/  body=json
    %-  pairs:enjs:format
    :~  ['ok' b+|]
        :-  'error'
        %-  pairs:enjs:format
        :~  ['code' s+code.failure]
            ['message' s+message.failure]
            ['retryable' b+retryable.failure]
            ['details' a+(turn details.failure |=(line=@t s+line))]
        ==
    ==
  (answer eyre-id status.failure headers body)
::
++  answer
  |=  [eyre-id=@ta status=@ud headers=header-list:http =json]
  ^-  (list card:agent:gall)
  %+  give:uhttp  eyre-id
  [[status headers] `(as-octs:mimes:html (en:json:html json))]
::
::  +|  Clay
::
++  clay-beam
  ::  The clay beam of `rel` under the policy root, at now.
  |=  [=policy =bowl:gall rel=path]
  ^-  path
  [(scot %p our.bowl) q.byk.bowl (scot %da now.bowl) (weld root.policy rel)]
::
++  stored
  ::  What clay holds at `rel` now: ~ for nothing, or the text it reads
  ::  as under `codec`.  A failed scry or an unreadable file is a tang.
  ::
  ::  Existence is asked of the tomb endpoint, so a deleted file whose
  ::  history remains reads as absent.
  |=  [=policy =bowl:gall rel=path =codec]
  ^-  (each (unit @t) tang)
  %-  mule  |.
  ^-  (unit @t)
  =/  beam=path  (clay-beam policy bowl rel)
  =/  tomb=path  ~[(snag 0 beam) %$ (snag 2 beam) %tomb]
  ?.  .^(? %cx (weld tomb beam))  ~
  ~|  "unreadable stored file {(spud rel)}"
      `(need (from-stored codec .^(* %cq beam)))
::
++  browse-paths
  ::  Every stored file at or under `rel`, relative to the policy root.
  ::
  ::  Recursive results are bound to typed faces before +weld: weld is
  ::  wet, and mulling a trap's own product through it loops.
  |=  [=policy =bowl:gall rel=path]
  ^-  (list path)
  |-  ^-  (list path)
  =/  =arch  .^(arch %cy (clay-beam policy bowl rel))
  =/  here=(list path)  ?~(fil.arch ~ ~[rel])
  =/  names=(list @ta)  (sort ~(tap in ~(key by dir.arch)) aor)
  =/  children=(list path)
    |-  ^-  (list path)
    ?~  names  ~
    =/  head=(list path)  ^$(rel (snoc rel i.names))
    =/  rest=(list path)  $(names t.names)
    (weld head rest)
  (weld here children)
--
