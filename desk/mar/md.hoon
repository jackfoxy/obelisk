::
::::  /hoon/md/mar
  ::
/?    310
=,  eyre
=,  mimes:html
|_  mud=@t
++  grow                                                ::  convert to
  |%  
  ++  mime  [/text/markdown (as-octs mud)]              ::  convert to %mime
  --
++  grab
  |%                                                    ::  convert from
  ++  mime  |=([p=mite q=octs] q.q)
  ++  noun  @t                                          ::  clam from %noun
  --
++  grad  %mime
--
