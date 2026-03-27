/-  *gemtext
/+  *docu, cram
|_  dcu=manx
++  grab
  |%
  ++  docu        dcu
  ++  elem        |=(a=manx a)
  ++  htm         |=(a=manx a)
  ++  hymn        |=(a=manx a)
  ++  x-htm       |=(a=manx a)
  ++  x-htm-elem  |=(a=manx a)
  ++  gmi         |=(gem=(list gmni) (gmi:to-docu gem))
  ++  html        |=(htm=@t (need (de-xml:^html htm)))
  ++  noun        |=(non=* (manx non))
  ++  txt         |=(tex=wain (txt:to-docu tex))
  ++  udon        |=(mud=@t elm:(static:cram (ream mud)))
  ++  md          |=(tex=wain (txt:to-docu tex))
  --
++  grow
  |%
  ++  noun  dcu
  --
++  grad  %noun
--
