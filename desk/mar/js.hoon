::  js: JavaScript source text
::
=,  mimes:html
|_  txt=@t
::
++  grab
  |%
  ++  noun  @t
  ++  mime  |=([p=mite q=octs] `@t`q.q)
  --
::
++  grow
  |%
  ++  noun  txt
  ++  mime  [/text/javascript (as-octs txt)]
  --
::
++  grad  %mime
--
