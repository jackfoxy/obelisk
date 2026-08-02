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
  ?-  -.parsed
    %.n  %.n
    %.y  =(part p.parsed)
  ==
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
  ?~  parts  %.y
  ?&  (valid-part i.parts)
      $(parts t.parts)
  ==
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
  ?~  prefix  %.y
  ?~  candidate  %.n
  ?&  =(i.prefix i.candidate)
      $(prefix t.prefix, candidate t.candidate)
  ==
::
++  logical-path
  |=  physical=path
  ^-  (unit relative-path:web)
  ?:  (lth (lent physical) 3)  ~
  ?.  =(%txt (rear physical))  ~
  =/  relative=relative-path:web
    (scag (dec (lent physical)) physical)
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
  =/  logical=(list relative-path:web)
    %+  turn
      %+  skim  (turn physical logical-path)
      |=(relative=(unit relative-path:web) ?=(^ relative))
    |=  relative=(unit relative-path:web)
    ?>  ?=(^ relative)
    u.relative
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
    =/  file=file-entry-dto:web  [relative %file]
    (weld parents ~[file])
  =/  index=(map relative-path:web file-kind:web)
    %+  roll  candidates
    |=  [entry=file-entry-dto:web index=(map relative-path:web file-kind:web)]
    =/  old=(unit file-kind:web)  (~(get by index) path.entry)
    ?:  ?&  ?=(^ old)
            =(%file u.old)
        ==
      index
    (~(put by index) path.entry kind.entry)
  =/  entries=(list file-entry-dto:web)
    %+  turn  ~(tap by index)
    |=  [relative=relative-path:web kind=file-kind:web]
    [relative kind]
  =.  entries
    (skim entries |=(entry=file-entry-dto:web !=(base path.entry)))
  (sort entries entry-lte)
::
++  text-cage
  |=  content=@t
  ^-  cage
  [%txt !>((to-wain:format content))]
::
++  text-from-cage
  |=  =cage
  ^-  (unit @t)
  ?.  =(%txt p.cage)  ~
  =/  decoded=(each @t tang)
    %-  mule  |.
    (of-wain:format !<(wain q.cage))
  ?-  -.decoded
    %.n  ~
    %.y  `p.decoded
  ==
::
++  save-verifies
  |=  [expected=@t result=riot:clay]
  ^-  ?
  ?~  result  %.n
  =/  decoded=(unit @t)  (text-from-cage r.u.result)
  ?~  decoded  %.n
  =(expected u.decoded)
--
