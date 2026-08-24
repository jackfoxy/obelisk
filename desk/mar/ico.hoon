::  %ico: Windows icon asset; octs preserves exact byte length.
::
|_  dat=octs
++  grow
  |%
  ++  mime  [/image/x-icon dat]
  --
++  grab
  |%
  ++  mime  |=([p=mite q=octs] q)
  ++  noun  octs
  --
++  grad  %mime
--
