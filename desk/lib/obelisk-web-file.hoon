::  Pure Clay path, text, and browse helpers for %obelisk-web.
::
/-  web=obelisk-web
|%
::
++  storage-root
  ^-  path
  /data/obelisk
::
++  storage-mark
  ^-  @tas
  %txt
::
++  file-timeout
  ^-  @dr
  ~s10
::
++  valid-storage-mark
  |=  mark=@tas
  ^-  ?
  =(%txt mark)
::
++  valid-part
  |=  part=@ta
  ^-  ?
  ?:  ?|  =(0 part)
          =('.' part)
          =('..' part)
      ==
    %.n
  =/  parsed=(each @tas tang)
    %-  mule  |.
    `@tas`(slav %tas part)
  ?:(?=(%.n -.parsed) %.n =(part p.parsed))
::
++  valid-scope
  |=  scope=@ta
  ^-  ?
  ?|  =(%scripts scope)
      =(%results scope)
  ==
::
++  valid-parts
  |=  parts=relative-path:web
  ^-  ?
  (levy parts valid-part)
::
++  valid-browse-path
  |=  relative=relative-path:web
  ^-  ?
  ?~  relative  %.y
  ?&  (valid-scope i.relative)
      (valid-parts relative)
  ==
::
++  valid-file-path
  |=  relative=relative-path:web
  ^-  ?
  ?&  (gte (lent relative) 2)
      (valid-browse-path relative)
  ==
::
++  save-conflict
  |=  [exists=? overwrite=?]
  ^-  ?
  ?&  exists
      !overwrite
  ==
::
++  browse-path
  |=  relative=relative-path:web
  ^-  path
  (weld storage-root relative)
::
++  storage-path
  |=  relative=relative-path:web
  ^-  path
  (snoc (browse-path relative) storage-mark)
::
++  clay-beam
  |=  [our=@p desk=desk case=case clay-path=path]
  ^-  path
  :*  (scot %p our)
      desk
      (scot case)
      clay-path
  ==
::
++  tomb-beam
  |=  resource=path
  ^-  path
  ?>  (gte (lent resource) 3)
  =/  prefix=path
    ~[(snag 0 resource) %$ (snag 2 resource) %tomb]
  (weld prefix resource)
::
++  path-prefix
  |=  [prefix=path candidate=path]
  ^-  ?
  =(prefix (scag (lent prefix) candidate))
::
++  logical-path
  |=  physical=path
  ^-  (unit relative-path:web)
  =/  normalized=path
    ?:  (path-prefix storage-root physical)
      (slag (lent storage-root) physical)
    physical
  ?:  (lth (lent normalized) 3)  ~
  ?.  =(%txt (rear normalized))  ~
  =/  relative=relative-path:web
    (scag (dec (lent normalized)) normalized)
  ?.  (valid-file-path relative)  ~
  `relative
::
++  parent-paths
  |=  relative=relative-path:web
  ^-  (list relative-path:web)
  =/  count=@ud  1
  |-
  ?:  (gte count (lent relative))  ~
  [(scag count relative) $(count +(count))]
::
++  path-text
  |=  relative=relative-path:web
  ^-  @t
  (crip (spud relative))
::
++  entry-lte
  |=  [a=file-entry-dto:web b=file-entry-dto:web]
  ^-  ?
  (aor (path-text path.a) (path-text path.b))
::
++  entries-from-physical
  |=  [base=relative-path:web physical=(list path)]
  ^-  (list file-entry-dto:web)
  =/  logical=(list relative-path:web)  (murn physical logical-path)
  =.  logical
    %+  skim  logical
    |=  relative=relative-path:web
    ?&  (path-prefix base relative)
        !=(base relative)
    ==
  =/  candidates=(list file-entry-dto:web)
    %-  zing
    %+  turn  logical
    |=  relative=relative-path:web
    =/  parents=(list file-entry-dto:web)
      %+  turn  (parent-paths relative)
      |=  parent=relative-path:web
      ^-(file-entry-dto:web [parent %directory])
    (snoc parents ^-(file-entry-dto:web [relative %file]))
  =/  index=(map relative-path:web file-kind:web)
    %+  roll  candidates
    |=  [entry=file-entry-dto:web index=(map relative-path:web file-kind:web)]
    ::  A file entry always wins over a directory entry at the same path.
    ::
    ?:  ?=([~ %file] (~(get by index) path.entry))  index
    (~(put by index) path.entry kind.entry)
  =/  entries=(list file-entry-dto:web)
    (skim ~(tap by index) |=(entry=file-entry-dto:web !=(base path.entry)))
  (sort entries entry-lte)
::
++  storage-wain
  |=  content=@t
  ^-  wain
  =/  lines=wain  (to-wain:format content)
  ?:  =(0 content)  lines
  =/  size=@ud  (met 3 content)
  ?.  =(10 (cut 3 [(dec size) 1] content))  lines
  (snoc lines '')
::
++  text-cage
  |=  content=@t
  ^-  cage
  [%txt !>((storage-wain content))]
::
++  text-from-cage
  |=  =cage
  ^-  (unit @t)
  ?.  =(%txt p.cage)  ~
  =/  decoded=(each @t tang)
    %-  mule  |.
    (of-wain:format ;;(wain q.q.cage))
  ?:(?=(%.n -.decoded) ~ `p.decoded)
::
++  save-verifies
  |=  [expected=@t result=riot:clay]
  ^-  ?
  ?~  result  %.n
  =/  decoded=(unit @t)  (text-from-cage r.u.result)
  ?~  decoded  %.n
  =(expected u.decoded)
--
