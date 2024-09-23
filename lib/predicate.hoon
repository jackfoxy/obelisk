/-  *ast
/+  *utils
|%
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
++  and
  |=  [l=$-((map @tas @) ?) r=$-((map @tas @) ?) c=(map @tas @)]
  ^-  ?
  &((l c) (r c))
::
++  and-not
  |=  [l=$-((map @tas @) ?) r=$-((map @tas @) ?) c=(map @tas @)]
  ^-  ?
  ?!(&((l c) (r c)))
::
++  or
  |=  [l=$-((map @tas @) ?) r=$-((map @tas @) ?) c=(map @tas @)]
  ^-  ?
  |((l c) (r c))
::
++  qc-foo
  |=  p=qualified-column
  ^-  @tas
  column.p
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
      ::                (~(has by column-types) (qc-foo `qualified-column`l))
      ::=/  r-exists=?  ?:  ?=(dime r)  %.y
      ::                (~(has by column-types) (qc-foo `qualified-column`r))
      ::::
      ::?:  &(?=(qualified-column l) ?=(qualified-column r))
      ::  ?:  &(?!(l-exists) ?!(r-exists))  always-true
      ::  ?.  &(l-exists r-exists)  always-false
      ::  ?:  %+  types-match  (~(got by column-types) (qc-foo l))
      ::                    (~(got by column-types) (qc-foo r))
      ::    %+  bake  %+  cury
      ::                  %+  cury  (cury eq-col-col (qc-foo l))
      ::                            (qc-foo r)
      ::                  (~(got by column-types) (qc-foo l))
      ::              (map @tas @)
      ::  ~|  "comparing columns of differing auras: ".
      ::      "{<(qc-foo l)>} {<(qc-foo r)>}"
      ::      !!
      ::::
      ::?:  &(?=(qualified-column l) ?=(dime r))
      ::  ?.  l-exists  always-false
      ::  ?:  (types-match (~(got by column-types) (qc-foo l)) -.r)
      ::    (bake (cury (cury (cury eq-lit-col +.r) (qc-foo l)) -.r) (map @tas @))
      ::  ~|  "comparing column and literal of different auras: ".
      ::      "{<l>} {<r>}"
      ::      !!
      ::::
      ::?:  &(?=(dime l) ?=(qualified-column r))
      ::  ?.  r-exists  always-false
      ::  ?:  (types-match -.l (~(got by column-types) (qc-foo r)))
      ::    (bake (cury (cury (cury eq-lit-col +.l) (qc-foo r)) -.l) (map @tas @))
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
                 (~(got by column-types) (qc-foo l))
               -.l
      =/  sane-typ
            (fold in-list & |=([n=@ state=?] ?:(((sane typ) n) state %.n)))
      ?.  sane-typ  ~|("type of IN list incorrect, should be {<typ>}" !!)
      ?:  ?=(qualified-column l)  
        (bake (cury (cury in-col-list (qc-foo l)) in-list) (map @tas @))
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
                 (~(got by column-types) (qc-foo l))
               -.l
      =/  sane-typ
            (fold in-list & |=([n=@ state=?] ?:(((sane typ) n) state %.n)))
      ?.  sane-typ  ~|("type of IN list incorrect, should be {<typ>}" !!)
      ?:  ?=(qualified-column l)  
        (bake (cury (cury not-in-col-list (qc-foo l)) in-list) (map @tas @))
      (bake (cury (cury not-in-lit-list +.l) in-list) (map @tas @))
    ==
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
    ?:  %+  types-match  (~(got by column-types) (qc-foo l))
                          (~(got by column-types) (qc-foo r))
      %+  bake  %+  cury
                    %+  cury  (cury col-col (qc-foo l))
                              (qc-foo r)
                    (~(got by column-types) (qc-foo l))
                (map @tas @)
    ~|  "comparing columns of differing auras: ".
        "{<(qc-foo l)>} {<(qc-foo r)>}"
        !!
                                                      ::  literal = column
  ?:  &(?=(dime l) ?=(qualified-column r))
    ?:  (types-match -.l (~(got by column-types) (qc-foo r)))
      (bake (cury (cury (cury lit-col +.l) (qc-foo r)) -.l) (map @tas @))
    ~|  "comparing column to literal of different aura: ".
        "{<(qc-foo r)>} {<l>}"
        !!
                                                      ::  column = literal
  ?:  &(?=(qualified-column l) ?=(dime r))
    ?:  (types-match (~(got by column-types) (qc-foo l)) -.r)
      (bake (cury (cury (cury col-lit (qc-foo l)) +.r) -.r) (map @tas @))
    ~|  "comparing column to literal of different aura: ".
        "{<(qc-foo l)>} {<r>}"
        !!
  ~|("can't get here" !!)
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
--