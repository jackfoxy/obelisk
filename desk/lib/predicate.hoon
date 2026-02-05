/-  *ast, *obelisk, *server-state
/+  *utils, mip   :: *mip does not build
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
  |=  $:  a=@
          b=[qualified-table:ast @tas]
          typ=@ta
          c=data-row
          ==
  ^-  ?
  ?:  ?=(%joined-row -.c)  =(a (~(got bi:mip data.c) -.b +.b))
  =(a (~(got by data.c) +.b))
::
++  eq-col-lit
  |=  $:  a=[qualified-table:ast @tas]
          b=@
          typ=@ta
          c=data-row
          ==
  ^-  ?
  ?:  ?=(%joined-row -.c)  =((~(got bi:mip data.c) -.a +.a) b)
  =((~(got by data.c) +.a) b)
::
++  eq-col-col
  |=  $:  a=[qualified-table:ast @tas]
          b=[qualified-table:ast @tas]
          typ=@ta
          c=data-row
          ==
  ^-  ?
  ?:  ?=(%joined-row -.c)  .=  (~(got bi:mip data.c) -.a +.a)
                               (~(got bi:mip data.c) -.b +.b)
  =((~(got by data.c) +.a) (~(got by data.c) +.b))
::
++  eq-lit-lit
  |=  [a=@ b=@ typ=@ta c=data-row]
  ^-  ?
  =(a b)
::
::  neq
::
++  neq-lit-col
  |=  $:  a=@
          b=[qualified-table:ast @tas]
          typ=@ta
          c=data-row
          ==
  ^-  ?
  ?:  ?=(%joined-row -.c)  ?!(=(a (~(got bi:mip data.c) -.b +.b)))
  ?!(=(a (~(got by data.c) +.b)))
::
++  neq-col-lit
  |=  $:  a=[qualified-table:ast @tas]
          b=@
          typ=@ta
          c=data-row
          ==
  ^-  ?
  ?:  ?=(%joined-row -.c)  ?!(=((~(got bi:mip data.c) -.a +.a) b))
  ?!(=((~(got by data.c) +.a) b))
::
++  neq-col-col
  |=  $:  a=[qualified-table:ast @tas]
          b=[qualified-table:ast @tas]
          typ=@ta
          c=data-row
          ==
  ^-  ?
  ?:  ?=(%joined-row -.c)   ?!  .=  (~(got bi:mip data.c) -.a +.a)
                                    (~(got bi:mip data.c) -.b +.b)
  ?!(=((~(got by data.c) +.a) (~(got by data.c) +.b)))
::
++  neq-lit-lit
  |=  [a=@ b=@ typ=@ta c=data-row]
  ^-  ?
  ?!(=(a b))
::
::  gt
::
++  gt-lit-col
  |=  $:  a=@
          b=[qualified-table:ast @tas]
          typ=@ta
          c=data-row
          ==
  ^-  ?
  ?:  ?=(%joined-row -.c)  
    ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
      ?:  =(a (~(got bi:mip data.c) -.b +.b))  %.n
      (alpha (~(got bi:mip data.c) -.b +.b) a)
    (gth a (~(got bi:mip data.c) -.b +.b))
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    ?:  =(a (~(got by data.c) +.b))  %.n
    (alpha (~(got by data.c) +.b) a)
  (gth a (~(got by data.c) +.b))
::
++  gt-col-lit
  |=  $:  a=[qualified-table:ast @tas]
          b=@
          typ=@ta
          c=data-row
          ==
  ^-  ?
  ?:  ?=(%joined-row -.c)
    ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
      ?:  =((~(got bi:mip data.c) -.a +.a) b)  %.n
      (alpha b (~(got bi:mip data.c) -.a +.a))
    (gth (~(got bi:mip data.c) -.a +.a) b)
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    ?:  =((~(got by data.c) +.a) b)  %.n
    (alpha b (~(got by data.c) +.a))
  (gth (~(got by data.c) +.a) b)
::
++  gt-col-col
  |=  $:  a=[qualified-table:ast @tas]
          b=[qualified-table:ast @tas]
          typ=@ta
          c=data-row
          ==
  ^-  ?
  ?:  ?=(%joined-row -.c)
    ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
      ?:  =((~(got bi:mip data.c) -.a +.a) (~(got bi:mip data.c) -.b +.b))
        %.n
      (alpha (~(got bi:mip data.c) -.b +.b) (~(got bi:mip data.c) -.a +.a))
     (gth (~(got bi:mip data.c) -.a +.a) (~(got bi:mip data.c) -.b +.b))
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    ?:  =((~(got by data.c) +.a) (~(got by data.c) +.b))  %.n
    (alpha (~(got by data.c) +.b) (~(got by data.c) +.a))
  (gth (~(got by data.c) +.a) (~(got by data.c) +.b))
::
++  gt-lit-lit
  |=  [a=@ b=@ typ=@ta c=data-row]
  ^-  ?
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    ?:  =(a b)  %.n
    (alpha b a)
  (gth a b)
::
::  gte
::
++  gte-lit-col
  |=  $:  a=@
          b=[qualified-table:ast @tas]
          typ=@ta
          c=data-row
          ==
  ^-  ?
  ?:  ?=(%joined-row -.c)  
    ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
      (alpha (~(got bi:mip data.c) -.b +.b) a)
    (gte a (~(got bi:mip data.c) -.b +.b))
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    (alpha (~(got by data.c) +.b) a)
  (gte a (~(got by data.c) +.b))
::
++  gte-col-lit
  |=  $:  a=[qualified-table:ast @tas]
          b=@
          typ=@ta
          c=data-row
          ==
  ^-  ?
  ?:  ?=(%joined-row -.c)  
    ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
      (alpha b (~(got bi:mip data.c) -.a +.a))
    (gte (~(got bi:mip data.c) -.a +.a) b)
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    (alpha b (~(got by data.c) +.a))
  (gte (~(got by data.c) +.a) b)
::
++  gte-col-col
  |=  $:  a=[qualified-table:ast @tas]
          b=[qualified-table:ast @tas]
          typ=@ta
          c=data-row
          ==
  ^-  ?
  ?:  ?=(%joined-row -.c)  
    ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
      (alpha (~(got bi:mip data.c) -.b +.b) (~(got bi:mip data.c) -.a +.a))
    (gte (~(got bi:mip data.c) -.a +.a) (~(got bi:mip data.c) -.b +.b))
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    (alpha (~(got by data.c) +.b) (~(got by data.c) +.a))
  (gte (~(got by data.c) +.a) (~(got by data.c) +.b))
::
++  gte-lit-lit
  |=  [a=@ b=@ typ=@ta c=data-row]
  ^-  ?
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    (alpha b a)
  (gte a b)
::
::  lt
::
++  lt-lit-col
  |=  $:  a=@
          b=[qualified-table:ast @tas]
          typ=@ta
          c=data-row
          ==
  ^-  ?
  ?:  ?=(%joined-row -.c)
    ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
      ?:  =(a (~(got bi:mip data.c) -.b +.b))  %.n
      (alpha a (~(got bi:mip data.c) -.b +.b))
    (lth a (~(got bi:mip data.c) -.b +.b))
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    ?:  =(a (~(got by data.c) +.b))  %.n
    (alpha a (~(got by data.c) +.b))
  (lth a (~(got by data.c) +.b))
::
++  lt-col-lit
  |=  $:  a=[qualified-table:ast @tas]
          b=@
          typ=@ta
          c=data-row
          ==
  ^-  ?
  ?:  ?=(%joined-row -.c)  
    ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
      ?:  =((~(got bi:mip data.c) -.a +.a) b)  %.n
      (alpha (~(got bi:mip data.c) -.a +.a) b)
    (lth (~(got bi:mip data.c) -.a +.a) b)
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    ?:  =((~(got by data.c) +.a) b)  %.n
    (alpha (~(got by data.c) +.a) b)
  (lth (~(got by data.c) +.a) b)
::
++  lt-col-col
  |=  $:  a=[qualified-table:ast @tas]
          b=[qualified-table:ast @tas]
          typ=@ta
          c=data-row
          ==
  ^-  ?
  ?:  ?=(%joined-row -.c)
    ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
      ?:  =((~(got bi:mip data.c) -.a +.a) (~(got bi:mip data.c) -.b +.b))
        %.n
      (alpha (~(got bi:mip data.c) -.a +.a) (~(got bi:mip data.c) -.b +.b))
    (lth (~(got bi:mip data.c) -.a +.a) (~(got bi:mip data.c) -.b +.b))
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    ?:  =((~(got by data.c) +.a) (~(got by data.c) +.b))  %.n
    (alpha (~(got by data.c) +.a) (~(got by data.c) +.b))
  (lth (~(got by data.c) +.a) (~(got by data.c) +.b))
::
++  lt-lit-lit
  |=  [a=@ b=@ typ=@ta c=data-row]
  ^-  ?
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    ?:  =(a b)  %.n
    (alpha a b)
  (lth a b)
::
::  lte
::
++  lte-lit-col
  |=  $:  a=@
          b=[qualified-table:ast @tas]
          typ=@ta
          c=data-row
          ==
  ^-  ?
  ?:  ?=(%joined-row -.c)
    ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
      (alpha a (~(got bi:mip data.c) -.b +.b))
    (lte a (~(got bi:mip data.c) -.b +.b))
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    (alpha a (~(got by data.c) +.b))
  (lte a (~(got by data.c) +.b))
::
++  lte-col-lit
  |=  $:  a=[qualified-table:ast @tas]
          b=@
          typ=@ta
          c=data-row
          ==
  ^-  ?
  ?:  ?=(%joined-row -.c)
    ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
      (alpha (~(got bi:mip data.c) -.a +.a) b)
    (lte (~(got bi:mip data.c) -.a +.a) b)
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    (alpha (~(got by data.c) +.a) b)
  (lte (~(got by data.c) +.a) b)
::
++  lte-col-col
  |=  $:  a=[qualified-table:ast @tas]
          b=[qualified-table:ast @tas]
          typ=@ta
          c=data-row
          ==
  ^-  ?
  ?:  ?=(%joined-row -.c)
    ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
      (alpha (~(got bi:mip data.c) -.a +.a) (~(got bi:mip data.c) -.b +.b))
    (lte (~(got bi:mip data.c) -.a +.a) (~(got bi:mip data.c) -.b +.b))
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    (alpha (~(got by data.c) +.a) (~(got by data.c) +.b))
  (lte (~(got by data.c) +.a) (~(got by data.c) +.b))
::
++  lte-lit-lit
  |=  [a=@ b=@ typ=@ta c=data-row]
  ^-  ?
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    (alpha a b)
  (lte a b)
::
::  in
::
++  in-lit-list
  |=  [a=@ b=(list @) c=data-row]
  ^-  ?
  |-
  ?~  b  %.n
  ?:  =(a -.b)  %.y
  $(b +.b)
::
++  in-col-list
  |=  $:  a=[qualified-table:ast @tas]
          b=(list @)
          c=data-row
          ==
  ^-  ? 
  =/  val  ?:  ?=(%joined-row -.c)  (~(got bi:mip data.c) -.a +.a)
           (~(got by data.c) +.a)
  |-
  ?~  b  %.n
  ?:  =(val -.b)  %.y
  $(b +.b)
::
::  not in
::
++  not-in-lit-list
  |=  [a=@ b=(list @) c=data-row]
  ^-  ?
  |-
  ?~  b  %.y
  ?:  =(a -.b)  %.n
  $(b +.b)
::
++  not-in-col-list
  |=  $:  a=[qualified-table:ast @tas]
          b=(list @)
          c=data-row
          ==
  ^-  ?
  =/  val  ?:  ?=(%joined-row -.c)  (~(got bi:mip data.c) -.a +.a)
               (~(got by data.c) +.a)
  |-
  ?~  b  %.y
  ?:  =(val -.b)  %.n
  $(b +.b)
::
::  not
::
++  not
  |=  $:  l=$-(data-row ?)
          c=data-row
          ==
  ^-  ?
  !(l c)
::
++  and
  |=  $:  l=$-(data-row ?)
          r=$-(data-row ?)
          c=data-row
          ==
  ^-  ?
  &((l c) (r c))
::
++  and-not
  |=  $:  l=$-(data-row ?)
          r=$-(data-row ?)
          c=data-row
          ==
  ^-  ?
  ?!(&((l c) (r c)))
::
++  or
  |=  $:  l=$-(data-row ?)
          r=$-(data-row ?)
          c=data-row
          ==
  ^-  ?
  |((l c) (r c))
::
::  +normalize-predicate:
::    [predicate:ast (map @tas (list qualified-table:ast))] -> predicate:ast
::
::  fail if column name available for multiple qualifiers
++  normalize-predicate
  |=  $:  p=predicate:ast
          qualifier-lookup=(map @tas (list qualified-table:ast))
          ==
  ^-  predicate:ast
  |-
  ?~  p  ~
  p(n (normalize-leaf n.p qualifier-lookup), l $(p l.p), r $(p r.p))
::
::  +normalize-leaf:
::    [predicate-component:ast (map @tas (list qualified-table:ast))]
::    -> predicate-component:ast
++  normalize-leaf
  |=  $:  a=predicate-component:ast
          qualifier-lookup=(map @tas (list qualified-table:ast))
          ==
  ^-  predicate-component:ast
  ?:  ?=(unqualified-column:ast a)             
    ?:  =((lent (~(got by qualifier-lookup) name.a)) 1)
      :^  %qualified-column
          (normalize-qt -:(~(got by qualifier-lookup) name.a))
          name.a
          alias.a
    ~|("undetermined qualifier for {<name.a>} in predicate" !!)
  ?:  ?=(qualified-column:ast a)
    :^  %qualified-column
        (normalize-qt qualifier.a)
        name.a
        alias.a
  a
::
::  +pred-unqualify-qualified:  predicate:ast -> predicate:ast
::
::  single table predicate must have unqualified-column
++  pred-unqualify-qualified
  |=  p=predicate:ast
  ^-  predicate:ast
  |-
  ?~  p  ~
  p(n (unqualify-leaf n.p), l $(p l.p), r $(p r.p))
::
::  +unqualify-leaf:  predicate-component:ast -> predicate-component:ast
++  unqualify-leaf
  |=  a=predicate-component:ast
  ^-  predicate-component:ast
  ?.  ?=(qualified-column:ast a)  a
  ::
  %:  unqualified-column:ast  %unqualified-column
                              name.a
                              alias.a
                              ==
::
::  +pred-ops-and-conjs
++  pred-ops-and-conjs
  |=  $:  p=predicate:ast
          =map-meta
          qualifier-lookup=(map @tas (list qualified-table:ast))
          ==
  ^-  $-(data-row ?)
  ?~  p  ~|("pred-ops-and-conjs can't get here" !!) 
  ?.  ?=(ops-and-conjs n.p)  ~|("pred-ops-and-conjs can't get here" !!)
  ?-  n.p
    ternary-op
      ?~  l.p  ~|("pred-ops-and-conjs can't get here" !!)
      ?~  r.p  ~|("pred-ops-and-conjs can't get here" !!)
      =/  ll=$-(data-row ?)  (pred-binary-op l.p map-meta qualifier-lookup)
      =/  rr=$-(data-row ?)  (pred-binary-op r.p map-meta qualifier-lookup)
      ?:  =(%between n.p)
        (bake (cury (cury and ll) rr) data-row)
      (bake (cury (cury and-not ll) rr) data-row)
    binary-op   (pred-binary-op p map-meta qualifier-lookup)
    unary-op    (pred-unary-op p map-meta qualifier-lookup)
    all-any-op  ~|("%all and %any not implemented" !!)
    conjunction
      ?~  l.p  ~|("pred-ops-and-conjs can't get here" !!)
      ?~  r.p  ~|("pred-ops-and-conjs can't get here" !!)
      =/  ll=$-(data-row ?)  (pred-ops-and-conjs l.p map-meta qualifier-lookup)
      =/  rr=$-(data-row ?)  (pred-ops-and-conjs r.p map-meta qualifier-lookup)
      ?:  =(%and n.p)
        (bake (cury (cury and ll) rr) data-row)
      (bake (cury (cury or ll) rr) data-row)
    ==
:: 
++  pred-unary-op
  |=  $:  p=predicate:ast
          =map-meta
          qualifier-lookup=(map @tas (list qualified-table:ast))
          ==
  ^-  $-(data-row ?)
  ?~  p  ~|("pred-unary-op can't get here" !!)
  ?~  l.p  ~|("pred-unary-op can't get here" !!)
  ?.  ?=(unary-op n.p)  ~|("pred-unary-op can't get here" !!)
  ::
  ?-  n.p
    %not
    :: this doesn't handle a qualified/unqualified column as argument
      =/  ll=$-(data-row ?)  (pred-ops-and-conjs l.p map-meta qualifier-lookup)
      (bake (cury not ll) data-row)
    %exists
      ~|("%exists not implemented" !!)
    %not-exists
      ~|("%not-exists not implemented" !!)
    ==
:: 
++  pred-binary-op
  |=  $:  p=predicate:ast
          =map-meta
          qualifier-lookup=(map @tas (list qualified-table:ast))
          ==
  ^-  $-(data-row ?)
  ?~  p                  ~|("pred-binary-op can't get here" !!)
  ?.  ?=(binary-op n.p)  ~|("pred-binary-op can't get here" !!)
  ?~  l.p                ~|("pred-binary-op can't get here" !!)
  ?~  r.p                ~|("pred-binary-op can't get here" !!)
  ::
  ?-  n.p
    %eq
      =/  l=datum:ast  ?:  ?=(unqualified-column:ast n.l.p)  n.l.p
                       ?:  ?=(qualified-column:ast n.l.p)  n.l.p
                       ?:  ?=(dime n.l.p)  n.l.p
                       ~|("pred-binary-op can't get here" !!)
      =/  r=datum:ast  ?:  ?=(unqualified-column:ast n.r.p)   n.r.p
                       ?:  ?=(qualified-column:ast n.r.p)   n.r.p
                       ?:  ?=(dime n.r.p)  n.r.p
                       ~|("pred-binary-op can't get here" !!)
      ?:  ?=(%qualified-map-meta -.map-meta)
        %:  datum-ops-qualified  l
                                 r
                                 +.map-meta
                                 qualifier-lookup
                                 eq-lit-lit
                                 eq-col-col
                                 eq-col-lit
                                 eq-lit-col
                                 ==
      %:  datum-ops-unqualified  l
                                 r
                                 +.map-meta
                                 eq-lit-lit
                                 eq-col-col
                                 eq-col-lit
                                 eq-lit-col
                                 ==
    inequality-op
      =/  l=datum:ast  ?:  ?=(unqualified-column:ast n.l.p)  n.l.p
                       ?:  ?=(qualified-column:ast n.l.p)  n.l.p
                       ?:  ?=(dime n.l.p)  n.l.p
                       ~|("pred-binary-op can't get here" !!)
      =/  r=datum:ast  ?:  ?=(unqualified-column:ast n.r.p)   n.r.p
                       ?:  ?=(qualified-column:ast n.r.p)   n.r.p
                       ?:  ?=(dime n.r.p)  n.r.p
                       ~|("pred-binary-op can't get here" !!)
      (pred-inequality-op n.p l r map-meta qualifier-lookup)
    %equiv
      :: to do: the commented code tests for existence in the wrong place
      ::        it needs to take place at run time and row-by-row
      ::    fix when outer joins implemented 
      ::=/  l=datum:ast  ?:  ?=(unqualified-column:ast n.l.p)  n.l.p
      ::             ?:  ?=(qualified-column:ast n.l.p)  n.l.p
      ::             ?:  ?=(dime n.l.p)  n.l.p
      ::             ~|("pred-binary-op can't get here" !!)
      ::=/  r=datum:ast  ?:  ?=(unqualified-column:ast n.r.p)   n.r.p
      ::             ?:  ?=(qualified-column:ast  n.r.p)   n.r.p
      ::             ?:  ?=(dime  n.r.p)   n.r.p
      ::             ~|("pred-binary-op can't get here" !!::)
      ::=/  l-exists=?  ?:  ?=(dime l)  %.y
      ::                (~(has by map-meta) name.l)
      ::=/  r-exists=?  ?:  ?=(dime r)  %.y
      ::                (~(has by map-meta) name.r)
      ::::
      ::?:  &(?=(qualified-column:ast l) ?=(qualified-column:ast r))
      ::  ?:  &(?!(l-exists) ?!(r-exists))  always-true
      ::  ?.  &(l-exists r-exists)  always-false
      ::  ?:  %+  types-match  -:(~(got by map-meta) [qualifier.l name.l])
      ::                    -:(~(got by map-meta) [qualifier.r name.r])
      ::    %+  bake  %+  cury
      ::                  %+  cury  (cury eq-col-col [qualifier.l name.l])
      ::                            [qualifier.r name.r]
      ::                  -:(~(got by map-meta) [qualifier.l name.l])
      ::              data-row
      ::  ~|  "comparing columns of different auras: ".
      ::      "{<name.l>} {<name.r>}"
      ::      !!
      ::::
      ::?:  &(?=(qualified-column:ast l) ?=(dime r))
      ::  ?.  l-exists  always-false
      ::  ?:  (types-match -:(~(got by map-meta) [qualifier.l name.l]) -.r)
      ::    %+  bake
      ::          (cury (cury (cury eq-lit-col +.r) [qualifier.l name.l]) -.r)
      ::          data-row
      ::  ~|  "comparing column and literal of different auras: ".
      ::      "{<l>} {<r>}"
      ::      !!
      ::::
      ::?:  &(?=(dime l) ?=(qualified-column:ast r))
      ::  ?.  r-exists  always-false
      ::  ?:  (types-match -.l -:(~(got by map-meta) [qualifier.r name.r]))
      ::    %+  bake
      ::          (cury (cury (cury eq-lit-col +.l) [qualifier.r name.r]) -.l)
      ::          data-row
      ::  ~|  "comparing column and literal of different auras: ".
      ::      "{<l>} {<r>}"
      ::      !!
      ::::
      ::?:  &(?=(dime l) ?=(dime r))
      ::  ?:  (types-match -.l -.r)
      ::    %+  bake  (cury (cury (cury eq-lit-lit +.l) +.r) -.l)
      ::              data-row
      ::  ~|  "comparing column literals of different auras: ".
      ::      "{<l>} {<r>}"
      ::      !!
      ::::
      ::~|("pred-binary-op can't get here" !!)
      ~|("%equiv not implemented" !!)
    %not-equiv
      ~|("%not-equiv not implemented" !!)
    %in
      (common-list-pred p map-meta in-col-list in-lit-list)
    %not-in
      (common-list-pred p map-meta not-in-col-list not-in-lit-list)
    ==
::
::
++  common-list-pred
  |=  $:  p=predicate:ast
          =map-meta
          list-pred=$-([[qualified-table:ast @tas] (list @) =data-row] ?)
          lit-list-pred=$-([@ (list @) =data-row] ?)
          ==
  ^-  $-(data-row ?)
  ?~  p                  ~|("common-list-pred can't get here" !!)
  ?~  l.p                ~|("common-list-pred can't get here" !!)
  ?~  r.p                ~|("common-list-pred can't get here" !!)
  =/  r=value-literals  ?:  ?=(value-literals n.r.p)  n.r.p
                        ~|("common-list-pred can't get here" !!)
  =/  in-list  %+  turn  (split-all (trip `@t`q.r) ";") 
                         |=(a=tape (rash (crip a) dem))
  =/  typ
    ?:  ?=(dime:ast n.l.p)  -.n.l.p
    ?:  ?&  ?=(qualified-column:ast n.l.p)
            ?=(%qualified-map-meta -.map-meta)
            ==
      -:(~(got bi:mip +.map-meta) qualifier.n.l.p name.n.l.p)
    ?:  ?&  ?=(unqualified-column:ast n.l.p)
            ?=(%unqualified-map-meta -.map-meta)
            ==
      -:(~(got by +.map-meta) name.n.l.p)
    ~|("common-list-pred can't get here" !!)
  ?.  (fold in-list & |=([n=@ state=?] ?:(((sane typ) n) state %.n)))
    ~|("type of IN list incorrect, should be {<typ>}" !!)
  ?:  ?=(unqualified-column:ast n.l.p)
    %+  bake  (cury (cury list-pred [*qualified-table:ast name.n.l.p]) in-list)
              data-row
  ?:  ?=(qualified-column:ast n.l.p)
    %+  bake  (cury (cury list-pred [qualifier.n.l.p name.n.l.p]) in-list)
              data-row
  ?:  ?=(dime n.l.p)
    (bake (cury (cury lit-list-pred +.n.l.p) in-list) data-row)
  ~|("common-list-pred can't get here" !!)
::
++  get-qualifier
  |=  $:  col=qualified-column:ast
          qualifier-lookup=(map @tas (list qualified-table:ast))
          ==
  ^-  qualified-table:ast
  =/  quals=(list qualified-table:ast)
        ~|  "{<name.qualifier.col>} in predicate ".
            "does not resolve to a table or view"
        ::
        (~(got by qualifier-lookup) name.col)
  ?~  quals  ~|("get-qualifier can't get here" !!)
  ?:  (gth (lent quals) 1)
    ~|("{<name.qualifier.col>} in predicate must be qualified" !!)
  -.quals
::
+$  column-column
  $-([[qualified-table:ast @tas] [qualified-table:ast @tas] @ta data-row] ?)
::
++  datum-ops-qualified
  |=  $:  l=datum:ast
          r=datum:ast
          map-meta=(mip:mip qualified-table @tas typ-addr)
          qualifier-lookup=(map @tas (list qualified-table:ast))
          lit-lit=$-([@ @ @ta data-row] ?)
          col-col=column-column
          col-lit=$-([[qualified-table:ast @tas] @ @ta data-row] ?)
          lit-col=$-([@ [qualified-table:ast @tas] @ta data-row] ?)
          ==
  ^-  $-(data-row ?)
  ::  literal = literal
  ?:  &(?=(dime l) ?=(dime r))
    ?:  (types-match -.l -.r)
      (bake (cury (cury (cury lit-lit +.l) +.r) -.l) data-row)
    ~|("comparing column literals of different auras:  {<l>} {<r>}" !!)
  ::  column = column
  ?:  &(?=(qualified-column:ast l) ?=(qualified-column:ast r))
    ?:  %+  types-match
              -:(~(got bi:mip map-meta) qualifier.l name.l)
              -:(~(got bi:mip map-meta) qualifier.r name.r)
      %+  bake  %+  cury
                    %+  cury  (cury col-col [qualifier.l name.l])
                              [qualifier.r name.r]
                    -:(~(got bi:mip map-meta) qualifier.l name.l)
                data-row
    ~|  "comparing columns of different auras: {<name.l>} ".
        "{<-:(~(got bi:mip map-meta) qualifier.l name.l)>} {<name.r>} ".
        "{<-:(~(got bi:mip map-meta) qualifier.r name.r)>}"
        !!
  ::  literal = column
  ?:  &(?=(dime l) ?=(qualified-column:ast r))
    ?:  (types-match -.l -:(~(got bi:mip map-meta) qualifier.r name.r))
      (bake (cury (cury (cury lit-col +.l) [qualifier.r name.r]) -.l) data-row)
    ~|  "comparing literal to column of different aura: ".
        "{<l>} {<name.r>} ".
        "{<-:(~(got bi:mip map-meta) qualifier.r name.r)>}"
        !!
  ::  column = literal
  ?:  &(?=(qualified-column:ast l) ?=(dime r))
    ?:  (types-match -:(~(got bi:mip map-meta) qualifier.l name.l) -.r)
      (bake (cury (cury (cury col-lit [qualifier.l name.l]) +.r) -.r) data-row)
    ~|  "comparing column to literal of different aura: {<name.l>} ".
        "{<-:(~(got bi:mip map-meta) qualifier.l name.l)>} {<r>}"
        !!
  ~|("datum-ops can't get here" !!)
::
++  datum-ops-unqualified
  |=  $:  l=datum:ast
          r=datum:ast
          map-meta=(map @tas typ-addr)
          lit-lit=$-([@ @ @ta data-row] ?)
          col-col=column-column
          col-lit=$-([[qualified-table:ast @tas] @ @ta data-row] ?)
          lit-col=$-([@ [qualified-table:ast @tas] @ta data-row] ?)
          ==
  ^-  $-(data-row ?)
::  literal = literal
  ?:  &(?=(dime l) ?=(dime r))
    ?:  (types-match -.l -.r)
      (bake (cury (cury (cury lit-lit +.l) +.r) -.l) data-row)
    ~|("comparing column literals of different auras: {<l>} {<r>}" !!)
  ::  column = column
  ?:  &(?=(unqualified-column:ast l) ?=(unqualified-column:ast r))
    ?:  %+  types-match  -:(~(got by map-meta) name.l)
                         -:(~(got by map-meta) name.r)
      %+  bake  %+  cury
                    %+  cury  (cury col-col [*qualified-table:ast name.l])
                              [*qualified-table:ast name.r]
                    -:(~(got by map-meta) name.l)
                data-row
    ~|  "comparing columns of different auras: {<name.l>} ".
        "{<-:(~(got by map-meta) name.l)>} {<name.r>} ".
        "{<-:(~(got by map-meta) name.r)>}"
        !!
  ::  literal = column
  ?:  &(?=(dime l) ?=(unqualified-column:ast r))
    ?:  (types-match -.l -:(~(got by map-meta) name.r))
      %+  bake  %+  cury
                    (cury (cury lit-col +.l) [*qualified-table:ast name.r])
                    -.l
                data-row
    ~|  "comparing literal to column of different aura: {<l>} {<name.r>} ".
        "{<-:(~(got by map-meta) name.r)>}"
        !!
  ::  column = literal
  ?:  &(?=(unqualified-column:ast l) ?=(dime r))
    ?:  (types-match -:(~(got by map-meta) name.l) -.r)
      %+  bake  %+  cury  %+  cury
                              (cury col-lit [*qualified-table:ast name.l])
                               +.r
                          -.r
                data-row
    ~|  "comparing column to literal of different aura: {<name.l>} ".
        "{<-:(~(got by map-meta) name.l)>} {<r>}"
        !!
  ::
  ~|("datum-ops can't get here" !!)
::
++  pred-inequality-op
  |=  $:  p=inequality-op
          l=datum:ast
          r=datum:ast
          =map-meta
          qualifier-lookup=(map @tas (list qualified-table:ast))
          ==
  ^-  $-(data-row ?)
  ?-  p
    %neq
      ?:  ?=(%qualified-map-meta -.map-meta)
        %:  datum-ops-qualified  l
                                 r
                                 +.map-meta
                                 qualifier-lookup
                                 neq-lit-lit
                                 neq-col-col
                                 neq-col-lit
                                 neq-lit-col
                                 ==
      %:  datum-ops-unqualified  l
                                 r
                                 +.map-meta
                                 neq-lit-lit
                                 neq-col-col
                                 neq-col-lit
                                 neq-lit-col
                                 ==
    %gt
      ?:  ?=(%qualified-map-meta -.map-meta)
        %:  datum-ops-qualified  l
                                 r
                                 +.map-meta
                                 qualifier-lookup
                                 gt-lit-lit
                                 gt-col-col
                                 gt-col-lit
                                 gt-lit-col
                                 ==
      %:  datum-ops-unqualified  l
                                 r
                                 +.map-meta
                                 gt-lit-lit
                                 gt-col-col
                                 gt-col-lit
                                 gt-lit-col
                                 ==
    %gte
      ?:  ?=(%qualified-map-meta -.map-meta)
        %:  datum-ops-qualified  l
                                 r
                                 +.map-meta
                                 qualifier-lookup
                                 gte-lit-lit
                                 gte-col-col
                                 gte-col-lit
                                 gte-lit-col
                                 ==
      %:  datum-ops-unqualified  l
                                 r
                                 +.map-meta
                                 gte-lit-lit
                                 gte-col-col
                                 gte-col-lit
                                 gte-lit-col
                                 ==
    %lt
      ?:  ?=(%qualified-map-meta -.map-meta)
        %:  datum-ops-qualified  l
                                 r
                                 +.map-meta
                                 qualifier-lookup
                                 lt-lit-lit
                                 lt-col-col
                                 lt-col-lit
                                 lt-lit-col
                                 ==
      %:  datum-ops-unqualified  l
                                 r
                                 +.map-meta
                                 lt-lit-lit
                                 lt-col-col
                                 lt-col-lit
                                 lt-lit-col
                                 ==
    %lte
      ?:  ?=(%qualified-map-meta -.map-meta)
        %:  datum-ops-qualified  l
                                 r
                                 +.map-meta
                                 qualifier-lookup
                                 lte-lit-lit
                                 lte-col-col
                                 lte-col-lit
                                 lte-lit-col
                                 ==
      %:  datum-ops-unqualified  l
                                 r
                                 +.map-meta
                                 lte-lit-lit
                                 lte-col-col
                                 lte-col-lit
                                 lte-lit-col
                                 ==
    ==
::    +split-all: [(list T) sep:(list t)] -> (list (list T))
::
::  Splits a list into multiple lists, delimited by another list.
::    Examples
::      > (split-all "abcdefabhijkablmn" "ab")
::      ~[~ "cdef" "hijk" "lmn"]
::    Source
++  split-all
  |*  [p=(list) sep=(list)]
  =/  c=(list (list _?>(?=(^ p) i.p)))  ~
  =/  len  (lent sep)
  =/  q=(list @)  (flop (fand sep p))
  |-  ^+  c
  ?~  p  c
  ?~  q  $(p ~, c [p c])
  ?:  =(i.q 0)
    $(c [~ [(slag (add len i.q) `(list _?>(?=(^ p) i.p))`p) c]], p ~)
  %=  $
    c  [(slag (add len i.q) `(list _?>(?=(^ p) i.p))`p) c]
    p  (scag i.q `(list _?>(?=(^ p) i.p))`p)
    q  t.q
  ==
--
