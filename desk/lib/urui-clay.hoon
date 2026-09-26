::  urui-clay: clay path validation and browse listings.
::
::  Paths are built relative to a consumer's storage root and validated
::  as data; nothing here reads or writes clay.
::
|%
::
++  file-path
  ::  Preserve an allowed suffix; otherwise append the first extension.
  ::  An empty extension list cannot name a file.
  |=  [root=path raw=@t exts=(list @ta)]
  ^-  (unit path)
  ?:  =(~ exts)  ~
  =/  parsed  (relative-path raw)
  ?~  parsed  ~
  =/  rel=path  u.parsed
  =/  suffix=@ta  (rear rel)
  =?  rel  !(lien exts |=(ext=@ta =(ext suffix)))
    (snoc rel (head exts))
  `(weld root rel)
::
++  browse-path
  ::  Only the empty string selects the root; slash-only paths fail.
  |=  [root=path raw=@t]
  ^-  (unit path)
  ?:  =('' raw)  `root
  =/  parsed  (relative-path raw)
  ?~  parsed  ~
  `(weld root u.parsed)
::
++  browse-json
  |=  [file=? children=(list @ta)]
  ^-  json
  %-  pairs:enjs:format
  :~  ['file' b+file]
      ['children' a+(turn children |=(name=@ta s+name))]
  ==
::
++  relative-path
  ::  Strip leading slashes, parse Clay syntax, and reject traversal.
  |=  raw=@t
  ^-  (unit path)
  =/  clean=@t
    =/  chars=tape  (trip raw)
    |-  ^-  @t
    ?~  chars  ''
    ?.  =('/' i.chars)  (crip chars)
    $(chars t.chars)
  =/  parsed=(unit path)
    %-  mole  |.
    (stab (cat 3 '/' clean))
  ?~  parsed  ~
  =/  rel=path  u.parsed
  ?:  =(~ rel)  ~
  ?.  %+  levy  rel
      |=  part=@ta
      ?&  !=('.' part)
          !=('..' part)
      ==
    ~
  `rel
--
