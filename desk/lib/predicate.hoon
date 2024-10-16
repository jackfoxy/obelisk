/-  *ast
/+  *utils
|%
::
::  +license:  MIT+n license
++  license
  ^-  @  %-  crip
  "Original Copyright 2024 Jack Fox".
  " ".
  "Permission is hereby granted, free of charge, to any person obtaining a ".
  "copy of this software and associated documentation files ".
  "(the \"Software\"), to deal in the Software without restriction, ".
  "including without limitation the rights to use, copy, modify, merge, ".
  "publish, distribute, sublicense, and/or sell copies of the Software, ".
  "and to permit persons to whom the Software is furnished to do so, ".
  "subject to the following conditions: ".
  " ".
  "The above original copyright notice, this permission notice and the words".
  " ".
  "\"I AM - CHRIST LIVES - SATAN BE GONE\"".
  "  ".
  "shall be included in all copies or substantial portions of the Software, ".
  "as well as the story".
  " ".
  "\"Jesus was crucified for exposing the corruption of the ruling class and ".
  "their rulers, the bankers\"".
  ",".
  " all unaltered.".
  " ".
  "THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, ".
  "EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF ".
  "MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. ".
  "IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,".
  " DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR ".
  "OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE ".
  "USE OR OTHER DEALINGS IN THE SOFTWARE."

::
::  $binary-op:            ?(%eq inequality-op %equiv %not-equiv %in %not-in)
::
++  types-match
  |=  [l=@ta r=@ta]
  ?|  =(l r)
      ?&  =(l ~.t) 
          |(=(r ~.ta) =(r ~.tas))
          ==
      ?&  =(l ~.ta) 
          |(=(r ~.t) =(r ~.tas))
          ==
      ?&  =(l ~.tas) 
          |(=(r ~.t) =(r ~.ta))
          ==
      ==
::
::  eq
::
++  eq-lit-col
  |=  [a=@ b=@tas typ=@ta c=(map @tas @)]
  ^-  ?
  =(a (~(got by c) b))
::
++  eq-col-lit
  |=  [a=@tas b=@ typ=@ta c=(map @tas @)]
  ^-  ?
  =((~(got by c) a) b)
::
++  eq-col-col
  |=  [a=@tas b=@tas typ=@ta c=(map @tas @)]
  ^-  ?
  =((~(got by c) a) (~(got by c) b))
::
++  eq-lit-lit
  |=  [a=@ b=@ typ=@ta c=(map @tas @)]
  ^-  ?
  =(a b)
::
::  eq on joins
::
++  eq-lit-col-2
  |=  $:  a=@
          b=[qualified-object @tas]
          typ=@ta
          c=(map qualified-object (map @tas @))
          ==
  ^-  ?
  =/  x=(map @tas @)  (~(got by c) -.b)
  =(a (~(got by x) +.b))
::
++  eq-col-lit-2
  |=  $:  a=[qualified-object @tas]
          b=@
          typ=@ta
          c=(map qualified-object (map @tas @))
          ==
  ^-  ?
  =/  x=(map @tas @)  (~(got by c) -.a)
  =((~(got by x) +.a) b)
::
++  eq-col-col-2
  |=  $:  a=[qualified-object @tas]
          b=[qualified-object @tas]
          typ=@ta
          c=(map qualified-object (map @tas @))
          ==
  ^-  ?
  =/  x=(map @tas @)  (~(got by c) -.a)
  =/  y=(map @tas @)  (~(got by c) -.b)
  =((~(got by x) +.a) (~(got by y) +.b))
::
++  eq-lit-lit-2
  |=  [a=@ b=@ typ=@ta c=(map qualified-object (map @tas @))]
  ^-  ?
  =(a b)
::
::  neq
::
++  neq-lit-col
  |=  [a=@ b=@tas typ=@ta c=(map @tas @)]
  ^-  ?
  ?!(=(a (~(got by c) b)))
::
++  neq-col-lit
  |=  [a=@tas b=@ typ=@ta c=(map @tas @)]
  ^-  ?
  ?!(=((~(got by c) a) b))
::
++  neq-col-col
  |=  [a=@tas b=@tas typ=@ta c=(map @tas @)]
  ^-  ?
  ?!(=((~(got by c) a) (~(got by c) b)))
::
++  neq-lit-lit
  |=  [a=@ b=@ typ=@ta c=(map @tas @)]
  ^-  ?
  ?!(=(a b))
::
::  neq on joins
::
++  neq-lit-col-2
  |=  $:  a=@
          b=[qualified-object @tas]
          typ=@ta
          c=(map qualified-object (map @tas @))
          ==
  ^-  ?
  =/  x=(map @tas @)  (~(got by c) -.b)
  ?!(=(a (~(got by x) +.b)))
::
++  neq-col-lit-2
  |=  $:  a=[qualified-object @tas]
          b=@
          typ=@ta
          c=(map qualified-object (map @tas @))
          ==
  ^-  ?
  =/  x=(map @tas @)  (~(got by c) -.a)
  ?!(=((~(got by x) +.a) b))
::
++  neq-col-col-2
  |=  $:  a=[qualified-object @tas]
          b=[qualified-object @tas]
          typ=@ta
          c=(map qualified-object (map @tas @))
          ==
  ^-  ?
  =/  x=(map @tas @)  (~(got by c) -.a)
  =/  y=(map @tas @)  (~(got by c) -.b)
  ?!(=((~(got by x) +.a) (~(got by y) +.b)))
::
++  neq-lit-lit-2
  |=  [a=@ b=@ typ=@ta c=(map qualified-object (map @tas @))]
  ^-  ?
  ?!(=(a b))
::
::  gt
::
++  gt-lit-col
  |=  [a=@ b=@tas typ=@ta c=(map @tas @)]
  ^-  ?
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    ?:  =(a (~(got by c) b))  %.n
    (alpha (~(got by c) b) a)
  (gth a (~(got by c) b))
::
++  gt-col-lit
  |=  [a=@tas b=@ typ=@ta c=(map @tas @)]
  ^-  ?
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    ?:  =((~(got by c) a) b)  %.n
    (alpha b (~(got by c) a))
  (gth (~(got by c) a) b)
::
++  gt-col-col
  |=  [a=@tas b=@tas typ=@ta c=(map @tas @)]
  ^-  ?
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    ?:  =((~(got by c) a) (~(got by c) b))  %.n
    (alpha (~(got by c) b) (~(got by c) a))
  (gth (~(got by c) a) (~(got by c) b))
::
++  gt-lit-lit
  |=  [a=@ b=@ typ=@ta c=(map @tas @)]
  ^-  ?
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    ?:  =(a b)  %.n
    (alpha b a)
  (gth a b)
::
::  gt on joins
::
++  gt-lit-col-2
  |=  $:  a=@
          b=[qualified-object @tas]
          typ=@ta
          c=(map qualified-object (map @tas @))
          ==
  ^-  ?
  =/  x=(map @tas @)  (~(got by c) -.b)
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    ?:  =(a (~(got by x) +.b))  %.n
    (alpha (~(got by x) +.b) a)
  (gth a (~(got by x) +.b))
::
++  gt-col-lit-2
  |=  $:  a=[qualified-object @tas]
          b=@
          typ=@ta
          c=(map qualified-object (map @tas @))
          ==
  ^-  ?
  =/  x=(map @tas @)  (~(got by c) -.a)
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    ?:  =((~(got by x) +.a) b)  %.n
    (alpha b (~(got by x) +.a))
  (gth (~(got by x) +.a) b)
::
++  gt-col-col-2
  |=  $:  a=[qualified-object @tas]
          b=[qualified-object @tas]
          typ=@ta
          c=(map qualified-object (map @tas @))
          ==
  ^-  ?
  =/  x=(map @tas @)  (~(got by c) -.a)
  =/  y=(map @tas @)  (~(got by c) -.b)
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    ?:  =((~(got by x) +.a) (~(got by y) +.b))  %.n
    (alpha (~(got by y) +.b) (~(got by x) +.a))
  (gth (~(got by x) +.a) (~(got by y) +.b))
::
++  gt-lit-lit-2
  |=  [a=@ b=@ typ=@ta c=(map qualified-object (map @tas @))]
  ^-  ?
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    ?:  =(a b)  %.n
    (alpha b a)
  (gth a b)
::
::  gte
::
++  gte-lit-col
  |=  [a=@ b=@tas typ=@ta c=(map @tas @)]
  ^-  ?
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    (alpha (~(got by c) b) a)
  (gte a (~(got by c) b))
::
++  gte-col-lit
  |=  [a=@tas b=@ typ=@ta c=(map @tas @)]
  ^-  ?
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    (alpha b (~(got by c) a))
  (gte (~(got by c) a) b)
::
++  gte-col-col
  |=  [a=@tas b=@tas typ=@ta c=(map @tas @)]
  ^-  ?
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    (alpha (~(got by c) b) (~(got by c) a))
  (gte (~(got by c) a) (~(got by c) b))
::
++  gte-lit-lit
  |=  [a=@ b=@ typ=@ta c=(map @tas @)]
  ^-  ?
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    (alpha b a)
  (gte a b)
::
::  gte on joins
::
++  gte-lit-col-2
  |=  $:  a=@
          b=[qualified-object @tas]
          typ=@ta
          c=(map qualified-object (map @tas @))
          ==
  ^-  ?
  =/  x=(map @tas @)  (~(got by c) -.b)
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    (alpha (~(got by x) +.b) a)
  (gte a (~(got by x) +.b))
::
++  gte-col-lit-2
  |=  $:  a=[qualified-object @tas]
          b=@
          typ=@ta
          c=(map qualified-object (map @tas @))
          ==
  ^-  ?
  =/  x=(map @tas @)  (~(got by c) -.a)
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    (alpha b (~(got by x) +.a))
  (gte (~(got by x) +.a) b)
::
++  gte-col-col-2
  |=  $:  a=[qualified-object @tas]
          b=[qualified-object @tas]
          typ=@ta
          c=(map qualified-object (map @tas @))
          ==
  ^-  ?
  =/  x=(map @tas @)  (~(got by c) -.a)
  =/  y=(map @tas @)  (~(got by c) -.b)
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    (alpha (~(got by y) +.b) (~(got by x) +.a))
  (gte (~(got by x) +.a) (~(got by y) +.b))
::
++  gte-lit-lit-2
  |=  [a=@ b=@ typ=@ta c=(map qualified-object (map @tas @))]
  ^-  ?
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    (alpha b a)
  (gte a b)
::
::  lt
::
++  lt-lit-col
  |=  [a=@ b=@tas typ=@ta c=(map @tas @)]
  ^-  ?
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    ?:  =(a (~(got by c) b))  %.n
    (alpha a (~(got by c) b))
  (lth a (~(got by c) b))
::
++  lt-col-lit
  |=  [a=@tas b=@ typ=@ta c=(map @tas @)]
  ^-  ?
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    ?:  =((~(got by c) a) b)  %.n
    (alpha (~(got by c) a) b)
  (lth (~(got by c) a) b)
::
++  lt-col-col
  |=  [a=@tas b=@tas typ=@ta c=(map @tas @)]
  ^-  ?
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    ?:  =((~(got by c) a) (~(got by c) b))  %.n
    (alpha (~(got by c) a) (~(got by c) b))
  (lth (~(got by c) a) (~(got by c) b))
::
++  lt-lit-lit
  |=  [a=@ b=@ typ=@ta c=(map @tas @)]
  ^-  ?
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    ?:  =(a b)  %.n
    (alpha a b)
  (lth a b)
::
::  lt on joins
::
++  lt-lit-col-2
  |=  $:  a=@
          b=[qualified-object @tas]
          typ=@ta
          c=(map qualified-object (map @tas @))
          ==
  ^-  ?
  =/  x=(map @tas @)  (~(got by c) -.b)
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    ?:  =(a (~(got by x) +.b))  %.n
    (alpha a (~(got by x) +.b))
  (lth a (~(got by x) +.b))
::
++  lt-col-lit-2
  |=  $:  a=[qualified-object @tas]
          b=@
          typ=@ta
          c=(map qualified-object (map @tas @))
          ==
  ^-  ?
  =/  x=(map @tas @)  (~(got by c) -.a)
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    ?:  =((~(got by x) +.a) b)  %.n
    (alpha (~(got by x) +.a) b)
  (lth (~(got by x) +.a) b)
::
++  lt-col-col-2
  |=  $:  a=[qualified-object @tas]
          b=[qualified-object @tas]
          typ=@ta
          c=(map qualified-object (map @tas @))
          ==
  ^-  ?
  =/  x=(map @tas @)  (~(got by c) -.a)
  =/  y=(map @tas @)  (~(got by c) -.b)
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    ?:  =((~(got by x) +.a) (~(got by y) +.b))  %.n
    (alpha (~(got by x) +.a) (~(got by y) +.b))
  (lth (~(got by x) +.a) (~(got by y) +.b))
::
++  lt-lit-lit-2
  |=  [a=@ b=@ typ=@ta c=(map qualified-object (map @tas @))]
  ^-  ?
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    ?:  =(a b)  %.n
    (alpha a b)
  (lth a b)
::
::  lte
::
++  lte-lit-col
  |=  [a=@ b=@tas typ=@ta c=(map @tas @)]
  ^-  ?
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    (alpha a (~(got by c) b))
  (lte a (~(got by c) b))
::
++  lte-col-lit
  |=  [a=@tas b=@ typ=@ta c=(map @tas @)]
  ^-  ?
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    (alpha (~(got by c) a) b)
  (lte (~(got by c) a) b)
::
++  lte-col-col
  |=  [a=@tas b=@tas typ=@ta c=(map @tas @)]
  ^-  ?
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    (alpha (~(got by c) a) (~(got by c) b))
  (lte (~(got by c) a) (~(got by c) b))
::
++  lte-lit-lit
  |=  [a=@ b=@ typ=@ta c=(map @tas @)]
  ^-  ?
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    (alpha a b)
  (lte a b)
::
::  lte on joins
::
++  lte-lit-col-2
  |=  $:  a=@
          b=[qualified-object @tas]
          typ=@ta
          c=(map qualified-object (map @tas @))
          ==
  ^-  ?
  =/  x=(map @tas @)  (~(got by c) -.b)
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    (alpha a (~(got by x) +.b))
  (lte a (~(got by x) +.b))
::
++  lte-col-lit-2
  |=  $:  a=[qualified-object @tas]
          b=@
          typ=@ta
          c=(map qualified-object (map @tas @))
          ==
  ^-  ?
  =/  x=(map @tas @)  (~(got by c) -.a)
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    (alpha (~(got by x) +.a) b)
  (lte (~(got by x) +.a) b)
::
++  lte-col-col-2
  |=  $:  a=[qualified-object @tas]
          b=[qualified-object @tas]
          typ=@ta
          c=(map qualified-object (map @tas @))
          ==
  ^-  ?
  =/  x=(map @tas @)  (~(got by c) -.a)
  =/  y=(map @tas @)  (~(got by c) -.b)
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    (alpha (~(got by x) +.a) (~(got by y) +.b))
  (lte (~(got by x) +.a) (~(got by y) +.b))
::
++  lte-lit-lit-2
  |=  [a=@ b=@ typ=@ta c=(map qualified-object (map @tas @))]
  ^-  ?
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    (alpha a b)
  (lte a b)
::
::  in
::
++  in-lit-list
  |=  [a=@ b=(list @) c=(map @tas @)]
  ^-  ?
  |-
  ?~  b  %.n
  ?:  =(a -.b)  %.y
  $(b +.b)
::
++  in-col-list
  |=  [a=@tas b=(list @) c=(map @tas @)]
  ^-  ?
  =/  val  (~(got by c) a)
  |-
  ?~  b  %.n
  ?:  =(val -.b)  %.y
  $(b +.b)
::
::  in on joins
::
++  in-lit-list-2
  |=  [a=@ b=(list @) c=(map qualified-object (map @tas @))]
  ^-  ?
  |-
  ?~  b  %.n
  ?:  =(a -.b)  %.y
  $(b +.b)
::
++  in-col-list-2
  |=  $:  a=[qualified-object @tas]
          b=(list @)
          c=(map qualified-object (map @tas @))
          ==
  ^-  ?
  =/  x=(map @tas @)  (~(got by c) -.a)
  =/  val  (~(got by x) +.a)
  |-
  ?~  b  %.n
  ?:  =(val -.b)  %.y
  $(b +.b)
::
::  not in
::
++  not-in-lit-list
  |=  [a=@ b=(list @) c=(map @tas @)]
  ^-  ?
  |-
  ?~  b  %.y
  ?:  =(a -.b)  %.n
  $(b +.b)
::
++  not-in-col-list
  |=  [a=@tas b=(list @) c=(map @tas @)]
  ^-  ?
  =/  val  (~(got by c) a)
  |-
  ?~  b  %.y
  ?:  =(val -.b)  %.n
  $(b +.b)
::
::  not in on joins
::
++  not-in-lit-list-2
  |=  [a=@ b=(list @) c=(map qualified-object (map @tas @))]
  ^-  ?
  |-
  ?~  b  %.y
  ?:  =(a -.b)  %.n
  $(b +.b)
::
++  not-in-col-list-2
  |=  $:  a=[qualified-object @tas]
          b=(list @)
          c=(map qualified-object (map @tas @))
          ==
  ^-  ?
  =/  x=(map @tas @)  (~(got by c) -.a)
  =/  val  (~(got by x) +.a)
  |-
  ?~  b  %.y
  ?:  =(val -.b)  %.n
  $(b +.b)
::
++  and
  |=  [l=$-((map @tas @) ?) r=$-((map @tas @) ?) c=(map @tas @)]
  ^-  ?
  &((l c) (r c))
::
++  and-2
  |=  $:  l=$-((map qualified-object (map @tas @)) ?)
          r=$-((map qualified-object (map @tas @)) ?)
          c=(map qualified-object (map @tas @))
          ==
  ^-  ?
  &((l c) (r c))
::
++  and-not
  |=  [l=$-((map @tas @) ?) r=$-((map @tas @) ?) c=(map @tas @)]
  ^-  ?
  ?!(&((l c) (r c)))
::
++  and-not-2
  |=  $:  l=$-((map qualified-object (map @tas @)) ?)
          r=$-((map qualified-object (map @tas @)) ?)
          c=(map qualified-object (map @tas @))
          ==
  ^-  ?
  ?!(&((l c) (r c)))
::
++  or
  |=  [l=$-((map @tas @) ?) r=$-((map @tas @) ?) c=(map @tas @)]
  ^-  ?
  |((l c) (r c))
::
++  or-2
  |=  $:  l=$-((map qualified-object (map @tas @)) ?)
          r=$-((map qualified-object (map @tas @)) ?)
          c=(map qualified-object (map @tas @))
          ==
  ^-  ?
  |((l c) (r c))
::
::  
++  pred-ops-and-conjs
  |=  [p=predicate column-types=(map @tas @ta)]
  ^-  $-((map @tas @) ?)
  ?~  p  ~|("can't get here" !!) 
  ?.  ?=(ops-and-conjs n.p)  ~|("can't get here" !!)
  ?-  n.p
    ternary-op
      ?~  l.p  ~|("can't get here" !!)
      ?~  r.p  ~|("can't get here" !!)
      =/  ll=$-((map @tas @) ?)  (pred-binary-op l.p column-types)
      =/  rr=$-((map @tas @) ?)  (pred-binary-op r.p column-types)
      ?:  =(%between n.p)  (bake (cury (cury and ll) rr) (map @tas @))
      (bake (cury (cury and-not ll) rr) (map @tas @))
    binary-op
      (pred-binary-op p column-types)
    unary-op
      ~|("%exists %not-exists not implemented" !!)
    all-any-op
      ~|("%all and %any not implemented" !!)
    conjunction
      ?~  l.p  ~|("can't get here" !!)
      ?~  r.p  ~|("can't get here" !!)
      =/  ll=$-((map @tas @) ?)  (pred-ops-and-conjs l.p column-types)
      =/  rr=$-((map @tas @) ?)  (pred-ops-and-conjs r.p column-types)
      ?:  =(%and n.p)  (bake (cury (cury and ll) rr) (map @tas @))
      (bake (cury (cury or ll) rr) (map @tas @))
    ==
::
::  
++  pred-ops-and-conjs-2
  |=  [p=predicate column-types=(map qualified-object (map @tas @ta))]
  ^-  $-((map qualified-object (map @tas @)) ?)
  ?~  p  ~|("can't get here" !!) 
  ?.  ?=(ops-and-conjs n.p)  ~|("can't get here" !!)
  ?-  n.p
    ternary-op
      ?~  l.p  ~|("can't get here" !!)
      ?~  r.p  ~|("can't get here" !!)
      =/  ll=$-((map qualified-object (map @tas @)) ?)  (pred-binary-op-2 l.p column-types)
      =/  rr=$-((map qualified-object (map @tas @)) ?)  (pred-binary-op-2 r.p column-types)
      ?:  =(%between n.p)  (bake (cury (cury and-2 ll) rr) (map qualified-object (map @tas @)))
      (bake (cury (cury and-not-2 ll) rr) (map qualified-object (map @tas @)))
    binary-op
      (pred-binary-op-2 p column-types)
    unary-op
      ~|("%exists %not-exists not implemented" !!)
    all-any-op
      ~|("%all and %any not implemented" !!)
    conjunction
      ?~  l.p  ~|("can't get here" !!)
      ?~  r.p  ~|("can't get here" !!)
      =/  ll=$-((map qualified-object (map @tas @)) ?)  (pred-ops-and-conjs-2 l.p column-types)
      =/  rr=$-((map qualified-object (map @tas @)) ?)  (pred-ops-and-conjs-2 r.p column-types)
      ?:  =(%and n.p)  (bake (cury (cury and-2 ll) rr) (map qualified-object (map @tas @)))
      (bake (cury (cury or-2 ll) rr) (map qualified-object (map @tas @)))
    ==
::
:: 
++  pred-binary-op
  |=  [p=predicate column-types=(map @tas @ta)]
  ^-  $-((map @tas @) ?)
  ?~  p  ~|("can't get here" !!)
  ?.  ?=(binary-op n.p)  ~|("can't get here" !!)
  ?~  l.p  ~|("can't get here" !!)
  ?~  r.p  ~|("can't get here" !!)
  ::
  ?-  n.p
    %eq
      =/  l=datum  ?:  ?=(qualified-column -.l.p)  -.l.p
                   ?:  ?=(dime -.l.p)  -.l.p
                   ~|("can't get here" !!)
      =/  r=datum  ?:  ?=(qualified-column -.r.p)  -.r.p
                   ?:  ?=(dime -.r.p)  -.r.p
                   ~|("can't get here" !!)
      (datum-ops l r column-types eq-lit-lit eq-col-col eq-col-lit eq-lit-col)
    inequality-op
      =/  l=datum  ?:  ?=(qualified-column -.l.p)  -.l.p
                   ?:  ?=(dime -.l.p)  -.l.p
                   ~|("can't get here" !!)
      =/  r=datum  ?:  ?=(qualified-column -.r.p)  -.r.p
                   ?:  ?=(dime -.r.p)  -.r.p
                   ~|("can't get here" !!)
      (pred-inequality-op n.p l r column-types)
    %equiv
      :: to do: the commented code tests for existence in the wrong place
      ::        it needs to take place at run time and row-by-row
      ::    fix when outer joins implemented 
      ::=/  l=datum  ?:  ?=(qualified-column -.l.p)  -.l.p
      ::             ?:  ?=(dime -.l.p)  -.l.p
      ::             ~|("can't get here" !!)
      ::=/  r=datum  ?:  ?=(qualified-column -.r.p)  -.r.p
      ::             ?:  ?=(dime -.r.p)  -.r.p
      ::             ~|("can't get here" !!::)
      ::=/  l-exists=?  ?:  ?=(dime l)  %.y
      ::                (~(has by column-types) column.l)
      ::=/  r-exists=?  ?:  ?=(dime r)  %.y
      ::                (~(has by column-types) column.r)
      ::::
      ::?:  &(?=(qualified-column l) ?=(qualified-column r))
      ::  ?:  &(?!(l-exists) ?!(r-exists))  always-true
      ::  ?.  &(l-exists r-exists)  always-false
      ::  ?:  %+  types-match  (~(got by column-types) column.l)
      ::                    (~(got by column-types) column.r)
      ::    %+  bake  %+  cury
      ::                  %+  cury  (cury eq-col-col column.l)
      ::                            column.r
      ::                  (~(got by column-types) column.l)
      ::              (map @tas @)
      ::  ~|  "comparing columns of differing auras: ".
      ::      "{<column.l>} {<column.r>}"
      ::      !!
      ::::
      ::?:  &(?=(qualified-column l) ?=(dime r))
      ::  ?.  l-exists  always-false
      ::  ?:  (types-match (~(got by column-types) column.l) -.r)
      ::    (bake (cury (cury (cury eq-lit-col +.r) column.l) -.r) (map @tas @))
      ::  ~|  "comparing column and literal of different auras: ".
      ::      "{<l>} {<r>}"
      ::      !!
      ::::
      ::?:  &(?=(dime l) ?=(qualified-column r))
      ::  ?.  r-exists  always-false
      ::  ?:  (types-match -.l (~(got by column-types) column.r))
      ::    (bake (cury (cury (cury eq-lit-col +.l) column.r) -.l) (map @tas @))
      ::  ~|  "comparing column and literal of different auras: ".
      ::      "{<l>} {<r>}"
      ::      !!
      ::::
      ::?:  &(?=(dime l) ?=(dime r))
      ::  ?:  (types-match -.l -.r)
      ::    (bake (cury (cury (cury eq-lit-lit +.l) +.r) -.l) (map @tas @))
      ::  ~|  "comparing column literals of different auras: ".
      ::      "{<l>} {<r>}"
      ::      !!
      ::::
      ::~|("can't get here" !!)
      ~|("%equiv not implemented" !!)
    %not-equiv
      ~|("%not-equiv not implemented" !!)
    %in
      =/  l=datum  ?:  ?=(qualified-column -.l.p)  -.l.p
                   ?:  ?=(dime -.l.p)  -.l.p
                   ~|("can't get here" !!)
      =/  r=value-literals    ?:  ?=(value-literals -.r.p)  -.r.p
                                  ~|("can't get here" !!)
      =/  in-list  %+  turn  (split-all (trip `@t`q.r) ";") 
                             |=(a=tape (rash (crip a) dem))
      =/  typ  ?:  ?=(qualified-column l)
                 (~(got by column-types) column.l)
               -.l
      =/  sane-typ
            (fold in-list & |=([n=@ state=?] ?:(((sane typ) n) state %.n)))
      ?.  sane-typ  ~|("type of IN list incorrect, should be {<typ>}" !!)
      ?:  ?=(qualified-column l)  
        (bake (cury (cury in-col-list column.l) in-list) (map @tas @))
      (bake (cury (cury in-lit-list +.l) in-list) (map @tas @))
    %not-in
      =/  l=datum  ?:  ?=(qualified-column -.l.p)  -.l.p
                   ?:  ?=(dime -.l.p)  -.l.p
                   ~|("can't get here" !!)
      =/  r=value-literals    ?:  ?=(value-literals -.r.p)  -.r.p
                                  ~|("can't get here" !!)
      =/  in-list  %+  turn  (split-all (trip `@t`q.r) ";") 
                             |=(a=tape (rash (crip a) dem))
      =/  typ  ?:  ?=(qualified-column l)
                 (~(got by column-types) column.l)
               -.l
      =/  sane-typ
            (fold in-list & |=([n=@ state=?] ?:(((sane typ) n) state %.n)))
      ?.  sane-typ  ~|("type of IN list incorrect, should be {<typ>}" !!)
      ?:  ?=(qualified-column l)  
        (bake (cury (cury not-in-col-list column.l) in-list) (map @tas @))
      (bake (cury (cury not-in-lit-list +.l) in-list) (map @tas @))
    ==
::
:: 
++  pred-binary-op-2
  |=  [p=predicate column-types=(map qualified-object (map @tas @ta))]
  ^-  $-((map qualified-object (map @tas @)) ?)
  ?~  p  ~|("can't get here" !!)
  ?.  ?=(binary-op n.p)  ~|("can't get here" !!)
  ?~  l.p  ~|("can't get here" !!)
  ?~  r.p  ~|("can't get here" !!)
  ::
  ?-  n.p
    %eq
      =/  l=datum  ?:  ?=(qualified-column -.l.p)  -.l.p
                   ?:  ?=(dime -.l.p)  -.l.p
                   ~|("can't get here" !!)
      =/  r=datum  ?:  ?=(qualified-column -.r.p)  -.r.p
                   ?:  ?=(dime -.r.p)  -.r.p
                   ~|("can't get here" !!)
      (datum-ops-2 l r column-types eq-lit-lit-2 eq-col-col-2 eq-col-lit-2 eq-lit-col-2)
    inequality-op
      =/  l=datum  ?:  ?=(qualified-column -.l.p)  -.l.p
                   ?:  ?=(dime -.l.p)  -.l.p
                   ~|("can't get here" !!)
      =/  r=datum  ?:  ?=(qualified-column -.r.p)  -.r.p
                   ?:  ?=(dime -.r.p)  -.r.p
                   ~|("can't get here" !!)
      (pred-inequality-op-2 n.p l r column-types)
    %equiv
      :: to do: the commented code tests for existence in the wrong place
      ::        it needs to take place at run time and row-by-row
      ::    fix when outer joins implemented 
      ::=/  l=datum  ?:  ?=(qualified-column -.l.p)  -.l.p
      ::             ?:  ?=(dime -.l.p)  -.l.p
      ::             ~|("can't get here" !!)
      ::=/  r=datum  ?:  ?=(qualified-column -.r.p)  -.r.p
      ::             ?:  ?=(dime -.r.p)  -.r.p
      ::             ~|("can't get here" !!::)
      ::=/  l-exists=?  ?:  ?=(dime l)  %.y
      ::                (~(has by column-types) column.l)
      ::=/  r-exists=?  ?:  ?=(dime r)  %.y
      ::                (~(has by column-types) column.r)
      ::::
      ::?:  &(?=(qualified-column l) ?=(qualified-column r))
      ::  ?:  &(?!(l-exists) ?!(r-exists))  always-true
      ::  ?.  &(l-exists r-exists)  always-false
      ::  ?:  %+  types-match  (~(got by column-types) [qualifier.l column.l])
      ::                    (~(got by column-types) [qualifier.r column.r])
      ::    %+  bake  %+  cury
      ::                  %+  cury  (cury eq-col-col [qualifier.l column.l])
      ::                            [qualifier.r column.r]
      ::                  (~(got by column-types) [qualifier.l column.l])
      ::              (map qualified-object (map @tas @))
      ::  ~|  "comparing columns of differing auras: ".
      ::      "{<[qualifier.l column.l]>} {<[qualifier.r column.r]>}"
      ::      !!
      ::::
      ::?:  &(?=(qualified-column l) ?=(dime r))
      ::  ?.  l-exists  always-false
      ::  ?:  (types-match (~(got by column-types) [qualifier.l column.l]) -.r)
      ::    (bake (cury (cury (cury eq-lit-col +.r) [qualifier.l column.l]) -.r) (map qualified-object (map @tas @)))
      ::  ~|  "comparing column and literal of different auras: ".
      ::      "{<l>} {<r>}"
      ::      !!
      ::::
      ::?:  &(?=(dime l) ?=(qualified-column r))
      ::  ?.  r-exists  always-false
      ::  ?:  (types-match -.l (~(got by column-types) [qualifier.r column.r]))
      ::    (bake (cury (cury (cury eq-lit-col +.l) [qualifier.r column.r]) -.l) (map qualified-object (map @tas @)))
      ::  ~|  "comparing column and literal of different auras: ".
      ::      "{<l>} {<r>}"
      ::      !!
      ::::
      ::?:  &(?=(dime l) ?=(dime r))
      ::  ?:  (types-match -.l -.r)
      ::    (bake (cury (cury (cury eq-lit-lit +.l) +.r) -.l) (map qualified-object (map @tas @)))
      ::  ~|  "comparing column literals of different auras: ".
      ::      "{<l>} {<r>}"
      ::      !!
      ::::
      ::~|("can't get here" !!)
      ~|("%equiv not implemented" !!)
    %not-equiv
      ~|("%not-equiv not implemented" !!)
    %in
      =/  l=datum  ?:  ?=(qualified-column -.l.p)  -.l.p
                   ?:  ?=(dime -.l.p)  -.l.p
                   ~|("can't get here" !!)
      =/  r=value-literals    ?:  ?=(value-literals -.r.p)  -.r.p
                                  ~|("can't get here" !!)
      =/  in-list  %+  turn  (split-all (trip `@t`q.r) ";") 
                             |=(a=tape (rash (crip a) dem))
      =/  typ  ?:  ?=(qualified-column l)
                 (~(got by (~(got by column-types) qualifier.l)) column.l)
               -.l
      =/  sane-typ
            (fold in-list & |=([n=@ state=?] ?:(((sane typ) n) state %.n)))
      ?.  sane-typ  ~|("type of IN list incorrect, should be {<typ>}" !!)
      ?:  ?=(qualified-column l)  
        (bake (cury (cury in-col-list-2 [qualifier.l column.l]) in-list) (map qualified-object (map @tas @)))
      (bake (cury (cury in-lit-list-2 +.l) in-list) (map qualified-object (map @tas @)))
    %not-in
      =/  l=datum  ?:  ?=(qualified-column -.l.p)  -.l.p
                   ?:  ?=(dime -.l.p)  -.l.p
                   ~|("can't get here" !!)
      =/  r=value-literals    ?:  ?=(value-literals -.r.p)  -.r.p
                                  ~|("can't get here" !!)
      =/  in-list  %+  turn  (split-all (trip `@t`q.r) ";") 
                             |=(a=tape (rash (crip a) dem))
      =/  typ  ?:  ?=(qualified-column l)
                 (~(got by (~(got by column-types) qualifier.l)) column.l)
               -.l
      =/  sane-typ
            (fold in-list & |=([n=@ state=?] ?:(((sane typ) n) state %.n)))
      ?.  sane-typ  ~|("type of IN list incorrect, should be {<typ>}" !!)
      ?:  ?=(qualified-column l)  
        (bake (cury (cury not-in-col-list-2 [qualifier.l column.l]) in-list) (map qualified-object (map @tas @)))
      (bake (cury (cury not-in-lit-list-2 +.l) in-list) (map qualified-object (map @tas @)))
    ==
::
::
++  datum-ops
  |=  $:  l=datum
          r=datum
          column-types=(map @tas @ta)
          lit-lit=$-([@ @ @ta (map @tas @)] ?)
          col-col=$-([@tas @tas @ta (map @tas @)] ?)
          col-lit=$-([@tas @ @ta (map @tas @)] ?)
          lit-col=$-([@ @tas @ta (map @tas @)] ?)
          ==
  ^-  $-((map @tas @) ?)
                                                          ::  literal = literal
  ?:  &(?=(dime l) ?=(dime r))
    ?:  (types-match -.l -.r)
      (bake (cury (cury (cury lit-lit +.l) +.r) -.l) (map @tas @))
    ~|  "comparing column literals of different auras: ".
        "{<l>} {<r>}"
        !!
                                                      ::  column = column
  ?:  &(?=(qualified-column l) ?=(qualified-column r))
    ?:  %+  types-match  (~(got by column-types) column.l)
                          (~(got by column-types) column.r)
      %+  bake  %+  cury
                    %+  cury  (cury col-col column.l)
                              column.r
                    (~(got by column-types) column.l)
                (map @tas @)
    ~|  "comparing columns of differing auras: ".
        "{<column.l>} {<column.r>}"
        !!
                                                      ::  literal = column
  ?:  &(?=(dime l) ?=(qualified-column r))
    ?:  (types-match -.l (~(got by column-types) column.r))
      (bake (cury (cury (cury lit-col +.l) column.r) -.l) (map @tas @))
    ~|  "comparing column to literal of different aura: ".
        "{<column.r>} {<l>}"
        !!
                                                      ::  column = literal
  ?:  &(?=(qualified-column l) ?=(dime r))
    ?:  (types-match (~(got by column-types) column.l) -.r)
      (bake (cury (cury (cury col-lit column.l) +.r) -.r) (map @tas @))
    ~|  "comparing column to literal of different aura: ".
        "{<column.l>} {<r>}"
        !!
  ~|("can't get here" !!)
::
::
++  datum-ops-2
  |=  $:  l=datum
          r=datum
          column-types=(map qualified-object (map @tas @ta))
          lit-lit=$-([@ @ @ta (map qualified-object (map @tas @))] ?)
          col-col=$-([[qualified-object @tas] [qualified-object @tas] @ta (map qualified-object (map @tas @))] ?)
          col-lit=$-([[qualified-object @tas] @ @ta (map qualified-object (map @tas @))] ?)
          lit-col=$-([@ [qualified-object @tas] @ta (map qualified-object (map @tas @))] ?)
          ==
  ^-  $-((map qualified-object (map @tas @)) ?)
                                                          ::  literal = literal
  ?:  &(?=(dime l) ?=(dime r))
    ?:  (types-match -.l -.r)
      (bake (cury (cury (cury lit-lit +.l) +.r) -.l) (map qualified-object (map @tas @)))
    ~|  "comparing column literals of different auras: ".
        "{<l>} {<r>}"
        !!
                                                      ::  column = column
  ?:  &(?=(qualified-column l) ?=(qualified-column r))
  ::  ?:  %+  types-match  (~(got by (~(got by column-types) qualifier.l) column.l))
  ::                       (~(got by (~(got by column-types) qualifier.r) column.r))
    ?:  %+  types-match  (~(got by (~(got by column-types) qualifier.l)) column.l)
                         (~(got by (~(got by column-types) qualifier.r)) column.r)
      %+  bake  %+  cury
                    %+  cury  (cury col-col [qualifier.l column.l])
                              [qualifier.r column.r]
                    (~(got by (~(got by column-types) qualifier.l)) column.l)
                (map qualified-object (map @tas @))
    ~|  "comparing columns of differing auras: ".
        "{<[qualifier.l column.l]>} {<[qualifier.r column.r]>}"
        !!
                                                      ::  literal = column
  ?:  &(?=(dime l) ?=(qualified-column r))
    ?:  (types-match -.l (~(got by (~(got by column-types) qualifier.r)) column.r))
      (bake (cury (cury (cury lit-col +.l) [qualifier.r column.r]) -.l) (map qualified-object (map @tas @)))
    ~|  "comparing column to literal of different aura: ".
        "{<[qualifier.r column.r]>} {<l>}"
        !!
                                                      ::  column = literal
  ?:  &(?=(qualified-column l) ?=(dime r))
    ?:  (types-match (~(got by (~(got by column-types) qualifier.l)) column.l) -.r)
      (bake (cury (cury (cury col-lit [qualifier.l column.l]) +.r) -.r) (map qualified-object (map @tas @)))
    ~|  "comparing column to literal of different aura: ".
        "{<[qualifier.l column.l]>} {<r>}"
        !!
  ~|("can't get here" !!)
::
::
++  pred-inequality-op
  |=  [p=inequality-op l=datum r=datum types=(map @tas @ta)]
  ^-  $-((map @tas @) ?)
  ?-  p
    %neq
      (datum-ops l r types neq-lit-lit neq-col-col neq-col-lit neq-lit-col)
    %gt
      (datum-ops l r types gt-lit-lit gt-col-col gt-col-lit gt-lit-col)
    %gte
      (datum-ops l r types gte-lit-lit gte-col-col gte-col-lit gte-lit-col)
    %lt
      (datum-ops l r types lt-lit-lit lt-col-col lt-col-lit lt-lit-col)
    %lte
      (datum-ops l r types lte-lit-lit lte-col-col lte-col-lit lte-lit-col)
    ==
::
::
++  pred-inequality-op-2
  |=  [p=inequality-op l=datum r=datum types=(map qualified-object (map @tas @ta))]
  ^-  $-((map qualified-object (map @tas @)) ?)
  ?-  p
    %neq
      (datum-ops-2 l r types neq-lit-lit-2 neq-col-col-2 neq-col-lit-2 neq-lit-col-2)
    %gt
      (datum-ops-2 l r types gt-lit-lit-2 gt-col-col-2 gt-col-lit-2 gt-lit-col-2)
    %gte
      (datum-ops-2 l r types gte-lit-lit-2 gte-col-col-2 gte-col-lit-2 gte-lit-col-2)
    %lt
      (datum-ops-2 l r types lt-lit-lit-2 lt-col-col-2 lt-col-lit-2 lt-lit-col-2)
    %lte
      (datum-ops-2 l r types lte-lit-lit-2 lte-col-col-2 lte-col-lit-2 lte-lit-col-2)
    ==
--