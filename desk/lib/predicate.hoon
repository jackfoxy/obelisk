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
  |=  $:  a=@
          b=[qualified-object @tas]
          typ=@ta
          c=(map qualified-object (map @tas @))
          ==
  ^-  ?
  =/  x=(map @tas @)  (~(got by c) -.b)
  =(a (~(got by x) +.b))
::
++  eq-col-lit
  |=  $:  a=[qualified-object @tas]
          b=@
          typ=@ta
          c=(map qualified-object (map @tas @))
          ==
  ^-  ?
  =/  x=(map @tas @)  (~(got by c) -.a)
  =((~(got by x) +.a) b)
::
++  eq-col-col
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
++  eq-lit-lit
  |=  [a=@ b=@ typ=@ta c=(map qualified-object (map @tas @))]
  ^-  ?
  =(a b)
::
::  neq
::
++  neq-lit-col
  |=  $:  a=@
          b=[qualified-object @tas]
          typ=@ta
          c=(map qualified-object (map @tas @))
          ==
  ^-  ?
  =/  x=(map @tas @)  (~(got by c) -.b)
  ?!(=(a (~(got by x) +.b)))
::
++  neq-col-lit
  |=  $:  a=[qualified-object @tas]
          b=@
          typ=@ta
          c=(map qualified-object (map @tas @))
          ==
  ^-  ?
  =/  x=(map @tas @)  (~(got by c) -.a)
  ?!(=((~(got by x) +.a) b))
::
++  neq-col-col
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
++  neq-lit-lit
  |=  [a=@ b=@ typ=@ta c=(map qualified-object (map @tas @))]
  ^-  ?
  ?!(=(a b))
::
::  gt
::
++  gt-lit-col
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
++  gt-col-lit
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
++  gt-col-col
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
++  gt-lit-lit
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
++  gte-col-lit
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
++  gte-col-col
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
++  gte-lit-lit
  |=  [a=@ b=@ typ=@ta c=(map qualified-object (map @tas @))]
  ^-  ?
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    (alpha b a)
  (gte a b)
::
::  lt
::
++  lt-lit-col
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
++  lt-col-lit
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
++  lt-col-col
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
++  lt-lit-lit
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
++  lte-col-lit
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
++  lte-col-col
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
++  lte-lit-lit
  |=  [a=@ b=@ typ=@ta c=(map qualified-object (map @tas @))]
  ^-  ?
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    (alpha a b)
  (lte a b)
::
::  in
::
++  in-lit-list
  |=  [a=@ b=(list @) c=(map qualified-object (map @tas @))]
  ^-  ?
  |-
  ?~  b  %.n
  ?:  =(a -.b)  %.y
  $(b +.b)
::
++  in-col-list
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
  |=  [a=@ b=(list @) c=(map qualified-object (map @tas @))]
  ^-  ?
  |-
  ?~  b  %.y
  ?:  =(a -.b)  %.n
  $(b +.b)
::
++  not-in-col-list
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
  |=  $:  l=$-((map qualified-object (map @tas @)) ?)
          r=$-((map qualified-object (map @tas @)) ?)
          c=(map qualified-object (map @tas @))
          ==
  ^-  ?
  &((l c) (r c))
::
++  and-not
  |=  $:  l=$-((map qualified-object (map @tas @)) ?)
          r=$-((map qualified-object (map @tas @)) ?)
          c=(map qualified-object (map @tas @))
          ==
  ^-  ?
  ?!(&((l c) (r c)))
::
++  or
  |=  $:  l=$-((map qualified-object (map @tas @)) ?)
          r=$-((map qualified-object (map @tas @)) ?)
          c=(map qualified-object (map @tas @))
          ==
  ^-  ?
  |((l c) (r c))
::  
++  pred-ops-and-conjs
  |=  $:  p=predicate
          column-types=(map qualified-object (map @tas @ta))
          qualifier-lookup=(map @tas (list qualified-object:ast))
          ==
  ^-  $-((map qualified-object (map @tas @)) ?)
  ?~  p  ~|("can't get here" !!) 
  ?.  ?=(ops-and-conjs n.p)  ~|("can't get here" !!)
  ?-  n.p
    ternary-op
      ?~  l.p  ~|("can't get here" !!)
      ?~  r.p  ~|("can't get here" !!)
      =/  ll=$-((map qualified-object (map @tas @)) ?)
            (pred-binary-op l.p column-types qualifier-lookup)
      =/  rr=$-((map qualified-object (map @tas @)) ?)
            (pred-binary-op r.p column-types qualifier-lookup)
      ?:  =(%between n.p)
        (bake (cury (cury and ll) rr) (map qualified-object (map @tas @)))
      (bake (cury (cury and-not ll) rr) (map qualified-object (map @tas @)))
    binary-op
      (pred-binary-op p column-types qualifier-lookup)
    unary-op
      ~|("%exists %not-exists not implemented" !!)
    all-any-op
      ~|("%all and %any not implemented" !!)
    conjunction
      ?~  l.p  ~|("can't get here" !!)
      ?~  r.p  ~|("can't get here" !!)
      =/  ll=$-((map qualified-object (map @tas @)) ?)
            (pred-ops-and-conjs l.p column-types qualifier-lookup)
      =/  rr=$-((map qualified-object (map @tas @)) ?)
            (pred-ops-and-conjs r.p column-types qualifier-lookup)
      ?:  =(%and n.p)
        (bake (cury (cury and ll) rr) (map qualified-object (map @tas @)))
      (bake (cury (cury or ll) rr) (map qualified-object (map @tas @)))
    ==
:: 
++  pred-binary-op
  |=  $:  p=predicate
          column-types=(map qualified-object (map @tas @ta))
          qualifier-lookup=(map @tas (list qualified-object:ast))
          ==
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
      %:  datum-ops  l
                     r
                     column-types
                     qualifier-lookup
                     eq-lit-lit
                     eq-col-col
                     eq-col-lit
                     eq-lit-col
                     ==
    inequality-op
      =/  l=datum  ?:  ?=(qualified-column -.l.p)  -.l.p
                   ?:  ?=(dime -.l.p)  -.l.p
                   ~|("can't get here" !!)
      =/  r=datum  ?:  ?=(qualified-column -.r.p)  -.r.p
                   ?:  ?=(dime -.r.p)  -.r.p
                   ~|("can't get here" !!)
      (pred-inequality-op n.p l r column-types qualifier-lookup)
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
      ::    %+  bake
      ::          (cury (cury (cury eq-lit-col +.r) [qualifier.l column.l]) -.r)
      ::          (map qualified-object (map @tas @))
      ::  ~|  "comparing column and literal of different auras: ".
      ::      "{<l>} {<r>}"
      ::      !!
      ::::
      ::?:  &(?=(dime l) ?=(qualified-column r))
      ::  ?.  r-exists  always-false
      ::  ?:  (types-match -.l (~(got by column-types) [qualifier.r column.r]))
      ::    %+  bake
      ::          (cury (cury (cury eq-lit-col +.l) [qualifier.r column.r]) -.l)
      ::          (map qualified-object (map @tas @))
      ::  ~|  "comparing column and literal of different auras: ".
      ::      "{<l>} {<r>}"
      ::      !!
      ::::
      ::?:  &(?=(dime l) ?=(dime r))
      ::  ?:  (types-match -.l -.r)
      ::    %+  bake  (cury (cury (cury eq-lit-lit +.l) +.r) -.l)
      ::              (map qualified-object (map @tas @))
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
      =/  typ
        ?.  ?=(qualified-column l)
          -.l
        ?:  (~(has by column-types) qualifier.l)
          (~(got by (~(got by column-types) qualifier.l)) column.l)
      %-  ~(got by (~(got by column-types) (get-qualifier l qualifier-lookup)))
            column.l
      =/  sane-typ
            (fold in-list & |=([n=@ state=?] ?:(((sane typ) n) state %.n)))
      ?.  sane-typ  ~|("type of IN list incorrect, should be {<typ>}" !!)
      ?:  ?=(qualified-column l)
        ?:  (~(has by column-types) qualifier.l)
          %+  bake  (cury (cury in-col-list [qualifier.l column.l]) in-list)
                    (map qualified-object (map @tas @))
        %+  bake  (cury (cury in-col-list [(get-qualifier l qualifier-lookup) column.l]) in-list)
                  (map qualified-object (map @tas @))
      %+  bake  (cury (cury in-lit-list +.l) in-list)
                (map qualified-object (map @tas @))
    %not-in
      =/  l=datum  ?:  ?=(qualified-column -.l.p)  -.l.p
                   ?:  ?=(dime -.l.p)  -.l.p
                   ~|("can't get here" !!)
      =/  r=value-literals    ?:  ?=(value-literals -.r.p)  -.r.p
                                  ~|("can't get here" !!)
      =/  in-list  %+  turn  (split-all (trip `@t`q.r) ";") 
                             |=(a=tape (rash (crip a) dem))
      =/  typ  ?.  ?=(qualified-column l)
                 -.l
                 ?:  (~(has by column-types) qualifier.l)
                   (~(got by (~(got by column-types) qualifier.l)) column.l)
                 (~(got by (~(got by column-types) (get-qualifier l qualifier-lookup))) column.l)
      =/  sane-typ
            (fold in-list & |=([n=@ state=?] ?:(((sane typ) n) state %.n)))
      ?.  sane-typ  ~|("type of IN list incorrect, should be {<typ>}" !!)
      ?:  ?=(qualified-column l)
        ?:  (~(has by column-types) qualifier.l)
          %+  bake  (cury (cury not-in-col-list [qualifier.l column.l]) in-list)
                    (map qualified-object (map @tas @))
        %+  bake  (cury (cury not-in-col-list [(get-qualifier l qualifier-lookup) column.l]) in-list)
                  (map qualified-object (map @tas @))
      %+  bake  (cury (cury not-in-lit-list +.l) in-list)
                (map qualified-object (map @tas @))
    ==
::
++  get-qualifier
  |=  $:  col=qualified-column
          qualifier-lookup=(map @tas (list qualified-object:ast))
          ==
  ^-  qualified-object:ast
  =/  quals=(list qualified-object:ast)
        ~|  "{<name.qualifier.col>} in predicate ".
            "does not resolve to a table or view"
        (~(got by qualifier-lookup) name.qualifier.col)
  ?~  quals  ~|("get-qualifier can't get here" !!)
  ?:  (gth (lent quals) 1)
    ~|("{<name.qualifier.col>} in predicate must be qualified" !!)
  -.quals
::
++  datum-ops
  |=  $:  l=datum
          r=datum
          column-types=(map qualified-object (map @tas @ta))
          qualifier-lookup=(map @tas (list qualified-object:ast))
          lit-lit=$-([@ @ @ta (map qualified-object (map @tas @))] ?)
          col-col=$-([[qualified-object @tas] [qualified-object @tas] @ta (map qualified-object (map @tas @))] ?)
          col-lit=$-([[qualified-object @tas] @ @ta (map qualified-object (map @tas @))] ?)
          lit-col=$-([@ [qualified-object @tas] @ta (map qualified-object (map @tas @))] ?)
          ==
  ^-  $-((map qualified-object (map @tas @)) ?)
                                                          ::  literal = literal
  ?:  &(?=(dime l) ?=(dime r))
    ?:  (types-match -.l -.r)
      %+  bake  (cury (cury (cury lit-lit +.l) +.r) -.l)
                (map qualified-object (map @tas @))
    ~|  "comparing column literals of different auras: ".
        "{<l>} {<r>}"
        !!
  ::
  :: necessary column qualifiers are present
                                                      ::  column = column
  ?:  &(?=(qualified-column l) ?=(qualified-column r) (~(has by column-types) qualifier.l) (~(has by column-types) qualifier.r))
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
  ?:  &(?=(dime l) ?=(qualified-column r) (~(has by column-types) qualifier.r))
    ?:  (types-match -.l (~(got by (~(got by column-types) qualifier.r)) column.r))
      %+  bake  (cury (cury (cury lit-col +.l) [qualifier.r column.r]) -.l)
                (map qualified-object (map @tas @))
    ~|  "comparing column to literal of different aura: ".
        "{<[qualifier.r column.r]>} {<l>}"
        !!
                                                      ::  column = literal
  ?:  &(?=(qualified-column l) ?=(dime r) (~(has by column-types) qualifier.l))
    ?:  (types-match (~(got by (~(got by column-types) qualifier.l)) column.l) -.r)
      %+  bake  (cury (cury (cury col-lit [qualifier.l column.l]) +.r) -.r)
                (map qualified-object (map @tas @))
    ~|  "comparing column to literal of different aura: ".
        "{<[qualifier.l column.l]>} {<r>}"
        !!
  ::
  :: one or more column qualifiers missing
                                                        ::  column = column
  ?:  &(?=(qualified-column l) ?=(qualified-column r) (~(has by column-types) qualifier.l))
    (l-unqualified-r l r column-types qualifier-lookup col-col)
  ?:  &(?=(qualified-column l) ?=(qualified-column r) (~(has by column-types) qualifier.r))
    (unqualified-l-r l r column-types qualifier-lookup col-col)
  ?:  &(?=(qualified-column l) ?=(qualified-column r))
    (unqualified-l-unqualified-r l r column-types qualifier-lookup col-col)
                                                      ::  literal = column
  ?:  &(?=(dime l) ?=(qualified-column r))
    (datum-unqualified-column l r column-types qualifier-lookup lit-col)
                                                      ::  column = literal
  ?:  &(?=(qualified-column l) ?=(dime r))
    (unqualified-column-datum l r column-types qualifier-lookup col-lit)
  ~|("datum-ops can't get here" !!)
::
++  unqualified-l-unqualified-r
  |=  $:  l=datum
          r=datum
          column-types=(map qualified-object (map @tas @ta))
          qualifier-lookup=(map @tas (list qualified-object:ast))
          col-col=$-([[qualified-object @tas] [qualified-object @tas] @ta (map qualified-object (map @tas @))] ?)
          ==
  ?.  &(?=(qualified-column l) ?=(qualified-column r))
    ~|("unqualified-l-unqualified-r can't get here" !!)
  ::
  =/  qual-l  (get-qualifier l qualifier-lookup)
  =/  qual-r  (get-qualifier r qualifier-lookup)
  ?:  %+  types-match  (~(got by (~(got by column-types) qual-l)) column.l)
                        (~(got by (~(got by column-types) qual-r)) column.r)
  %+  bake  %+  cury
                %+  cury  (cury col-col [qual-l column.l])
                          [qual-r column.r]
                (~(got by (~(got by column-types) qual-l)) column.l)
            (map qualified-object (map @tas @))
  ~|  "comparing columns of different aura: ".
      "{<[qual-l column.l]>} {<[qual-r column.r]>}"
      !!
::
++  unqualified-l-r
  |=  $:  l=datum
          r=datum
          column-types=(map qualified-object (map @tas @ta))
          qualifier-lookup=(map @tas (list qualified-object:ast))
          col-col=$-([[qualified-object @tas] [qualified-object @tas] @ta (map qualified-object (map @tas @))] ?)
          ==
  ?.  &(?=(qualified-column l) ?=(qualified-column r))
    ~|("unqualified-l-r can't get here" !!)
  =/  qual  (get-qualifier l qualifier-lookup)
  ?:  %+  types-match  (~(got by (~(got by column-types) qual)) column.l)
                       (~(got by (~(got by column-types) qualifier.r)) column.r)
    %+  bake  %+  cury
                  %+  cury  (cury col-col [qual column.l])
                            [qualifier.r column.r]
                  (~(got by (~(got by column-types) qual)) column.l)
              (map qualified-object (map @tas @))
  ~|  "comparing columns of different aura: ".
      "{<[qual column.l]>} {<r>}"
      !!
::
++  l-unqualified-r
  |=  $:  l=datum
          r=datum
          column-types=(map qualified-object (map @tas @ta))
          qualifier-lookup=(map @tas (list qualified-object:ast))
          col-col=$-([[qualified-object @tas] [qualified-object @tas] @ta (map qualified-object (map @tas @))] ?)
          ==
  ?.  &(?=(qualified-column l) ?=(qualified-column r))
    ~|("l-unqualified-r can't get here" !!)
  =/  qual  (get-qualifier r qualifier-lookup)
  ?:  %+  types-match  (~(got by (~(got by column-types) qualifier.l)) column.l)
                          (~(got by (~(got by column-types) qual)) column.r)
    %+  bake  %+  cury
                  %+  cury  (cury col-col [qualifier.l column.l])
                            [qual column.r]
                  (~(got by (~(got by column-types) qualifier.l)) column.l)
              (map qualified-object (map @tas @))
  ~|  "comparing columns of different aura: ".
      "{<l>} {<[qual column.r]>}"
      !!
::
++  datum-unqualified-column
  |=  $:  l=datum
          r=datum
          column-types=(map qualified-object (map @tas @ta))
          qualifier-lookup=(map @tas (list qualified-object:ast))
          lit-col=$-([@ [qualified-object @tas] @ta (map qualified-object (map @tas @))] ?)
          ==
  ?.  &(?=(dime l) ?=(qualified-column r))
    ~|("datum-unqualified-column can't get here" !!)
  =/  qual  (get-qualifier r qualifier-lookup)
  ?:  (types-match -.l (~(got by (~(got by column-types) qual)) column.r))
        %+  bake  (cury (cury (cury lit-col +.l) [qual column.r]) -.l)
                  (map qualified-object (map @tas @))
  ~|  "comparing literal to column of different aura: ".
      "{<l>} {<[qual column.r]>}"
      !!
::
++  unqualified-column-datum
  |=  $:  l=datum
          r=datum
          column-types=(map qualified-object (map @tas @ta))
          qualifier-lookup=(map @tas (list qualified-object:ast))
          col-lit=$-([[qualified-object @tas] @ @ta (map qualified-object (map @tas @))] ?)
          ==
  ?.  &(?=(qualified-column l) ?=(dime r))
    ~|("unqualified-column-datum can't get here" !!)
  =/  qual  (get-qualifier l qualifier-lookup)
  ?:  (types-match (~(got by (~(got by column-types) qual)) column.l) -.r)
    %+  bake  (cury (cury (cury col-lit [qual column.l]) +.r) -.r)
              (map qualified-object (map @tas @))
  ~|  "comparing column to literal of different aura: ".
      "{<[qual column.l]>} {<r>}"
      !!
::
++  pred-inequality-op
  |=  $:  p=inequality-op
          l=datum
          r=datum
          column-types=(map qualified-object (map @tas @ta))
          qualifier-lookup=(map @tas (list qualified-object:ast))
          ==
  ^-  $-((map qualified-object (map @tas @)) ?)
  ?-  p
    %neq
      %:  datum-ops  l
                     r
                     column-types
                     qualifier-lookup
                     neq-lit-lit
                     neq-col-col
                     neq-col-lit
                     neq-lit-col
                     ==
    %gt
      %:  datum-ops  l
                     r
                     column-types
                     qualifier-lookup
                     gt-lit-lit
                     gt-col-col
                     gt-col-lit
                     gt-lit-col
                     ==
    %gte
      %:  datum-ops  l
                     r
                     column-types
                     qualifier-lookup
                     gte-lit-lit
                     gte-col-col
                     gte-col-lit
                     gte-lit-col
                     ==
    %lt
      %:  datum-ops  l
                     r
                     column-types
                     qualifier-lookup
                     lt-lit-lit
                     lt-col-col
                     lt-col-lit
                     lt-lit-col
                     ==
    %lte
      %:  datum-ops  l
                     r
                     column-types
                     qualifier-lookup
                     lte-lit-lit
                     lte-col-col
                     lte-col-lit
                     lte-lit-col
                     ==
    ==
--