/-  *ast, *obelisk, *server-state
/+  *utils, mip   :: *mip does not build
|%
::
++  license
  ::  MIT+n license
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
++  prepare-predicate
  ::  Main entry point for converting a predicate AST into an executable gate.
  ::
  ::  Takes a parsed predicate tree and compiles it into a gate that evaluates
  ::  whether a data-row satisfies the predicate conditions.
  ::
  ::  Arguments:
  ::    p: predicate AST tree from the parser
  ::    map-meta: column metadata (types and addresses) for validation
  ::    qualifier-lookup: map of column names to their qualified table
  ::      references
  ::
  ::  Returns:
  ::    A gate $-(data-row ?) that evaluates the predicate against a row
  ::
  ::  Handles all predicate operations recursively:
  ::    - ternary-op: BETWEEN/NOT BETWEEN (combines two binary predicates)
  ::    - binary-op: =, !=, >, <, >=, <=, IN, NOT IN
  ::        (delegates to pred-binary-op)
  ::    - unary-op: NOT, EXISTS, NOT EXISTS (delegates to pred-unary-op)
  ::    - conjunction: AND/OR (recursively combines left and right predicates)
  ::    - all-any-op: ALL/ANY (not yet implemented)
  ::
  |=  [p=predicate:ast =map-meta =qualifier-lookup]
  ^-  $-(data-row ?)
  ?~  p  ~|("prepare-predicate can't get here 1" !!) 
  ?.  ?=(ops-and-conjs n.p)  ~|("prepare-predicate can't get here 2" !!)
  ?-  n.p
    ternary-op
      ?~  l.p  ~|("prepare-predicate can't get here 3" !!)
      ?~  r.p  ~|("prepare-predicate can't get here 4" !!)
      =/  ll=$-(data-row ?)  (pred-binary-op l.p map-meta qualifier-lookup)
      =/  rr=$-(data-row ?)  (pred-binary-op r.p map-meta qualifier-lookup)
      ?:  =(%between n.p)
        (bake (cury (cury and ll) rr) data-row)
      (bake (cury (cury and-not ll) rr) data-row)
    binary-op   (pred-binary-op p map-meta qualifier-lookup)
    unary-op    (pred-unary-op p map-meta qualifier-lookup)
    all-any-op  ~|("%all and %any not implemented" !!)
    conjunction
      ?~  l.p  ~|("prepare-predicate can't get here 5" !!)
      ?~  r.p  ~|("prepare-predicate can't get here 6" !!)
      =/  ll=$-(data-row ?)  (prepare-predicate l.p map-meta qualifier-lookup)
      =/  rr=$-(data-row ?)  (prepare-predicate r.p map-meta qualifier-lookup)
      ?:  =(%and n.p)
        (bake (cury (cury and ll) rr) data-row)
      (bake (cury (cury or ll) rr) data-row)
    ==
:: 
++  pred-unary-op
  |=  [p=predicate:ast =map-meta =qualifier-lookup]
  ^-  $-(data-row ?)
  ?~  p  ~|("pred-unary-op can't get here" !!)
  ?~  l.p  ~|("pred-unary-op can't get here" !!)
  ?.  ?=(unary-op n.p)  ~|("pred-unary-op can't get here" !!)
  ::
  ?-  n.p
    %not
    :: this doesn't handle a qualified/unqualified column as argument
      =/  ll=$-(data-row ?)  (prepare-predicate l.p map-meta qualifier-lookup)
      (bake (cury not ll) data-row)
    %exists
      ~|("%exists not implemented" !!)
    %not-exists
      ~|("%not-exists not implemented" !!)
    ==
:: 
++  pred-binary-op
  |=  [p=predicate:ast =map-meta =qualifier-lookup]
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
        %:  datum-ops-qualified-eq  l
                                    r
                                    +.map-meta
                                    qualifier-lookup
                                    eq-lit-lit
                                    eq-col-col
                                    eq-col-lit
                                    eq-lit-col
                                    ==
      %:  datum-ops-unqualified-eq  l
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
++  common-list-pred
  |=  $:  p=predicate:ast
          =map-meta
          list-pred=$-([@ (list @) =data-row] ?)
          lit-list-pred=$-([@ (list @) =data-row] ?)
          ==
  ^-  $-(data-row ?)
  ?~  p                  ~|("common-list-pred can't get here 1" !!)
  ?~  l.p                ~|("common-list-pred can't get here 2" !!)
  ?~  r.p                ~|("common-list-pred can't get here 3" !!)
  =/  r=value-literals  ?:  ?=(value-literals n.r.p)  n.r.p
                        ~|("common-list-pred can't get here 4" !!)
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
    ?:  ?&  ?=(qualified-column:ast n.l.p)
            ?=(%unqualified-map-meta -.map-meta)
            ==
      -:(~(got by +.map-meta) name.n.l.p)
    ~|("common-list-pred can't get here 5" !!)
  ?.  (fold in-list & |=([n=@ state=?] ?:(((sane typ) n) state %.n)))
    ~|("type of IN list incorrect, should be {<typ>}" !!)
  ?:  ?&  ?=(unqualified-column:ast n.l.p)
          ?=(%unqualified-map-meta -.map-meta)
          ==
    %+  bake  (cury (cury list-pred +:(~(got by +.map-meta) name.n.l.p)) in-list)
              data-row
  ?:  ?&  ?=(qualified-column:ast n.l.p)
          ?=(%qualified-map-meta -.map-meta)
          ==
    %+  bake  %+  cury
                  (cury list-pred +:(~(got bi:mip +.map-meta) qualifier.n.l.p name.n.l.p))
                  in-list
              data-row
  ?:  ?&  ?=(qualified-column:ast n.l.p)
          ?=(%unqualified-map-meta -.map-meta)
          ==
    %+  bake  (cury (cury list-pred +:(~(got by +.map-meta) name.n.l.p)) in-list)
              data-row
  ?:  ?=(dime n.l.p)
    (bake (cury (cury lit-list-pred +.n.l.p) in-list) data-row)
  ~|("common-list-pred can't get here 6" !!)
::
++  get-qualifier
  |=  [col=qualified-column:ast =qualifier-lookup]
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
  $-([@ @ @ta data-row] ?)
::
++  datum-ops-qualified
  |=  $:  l=datum:ast
          r=datum:ast
          map-meta=(mip:mip qualified-table @tas typ-addr)
          =qualifier-lookup
          lit-lit=$-([@ @ @ta data-row] ?)
          col-col=column-column
          col-lit=$-([@ @ @ta data-row] ?)
          lit-col=$-([@ @ @ta data-row] ?)
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
              ~|  "column {<name.l>} does not exist"
              -:(~(got bi:mip map-meta) qualifier.l name.l)
              ~|  "column {<name.r>} does not exist"
              -:(~(got bi:mip map-meta) qualifier.r name.r)
      %+  bake  %+  cury
                    %+  cury  (cury col-col +:(~(got bi:mip map-meta) qualifier.l name.l))
                              +:(~(got bi:mip map-meta) qualifier.r name.r)
                    -:(~(got bi:mip map-meta) qualifier.l name.l)
                data-row
    ~|  "comparing columns of different auras: {<name.l>} ".
        "{<-:(~(got bi:mip map-meta) qualifier.l name.l)>} {<name.r>} ".
        "{<-:(~(got bi:mip map-meta) qualifier.r name.r)>}"
        !!
  ::  literal = column
  ?:  &(?=(dime l) ?=(qualified-column:ast r))
    ~|  "column {<name.r>} does not exist"
    ?:  (types-match -.l -:(~(got bi:mip map-meta) qualifier.r name.r))
      %+  bake  %+  cury
                    (cury (cury lit-col +.l) +:(~(got bi:mip map-meta) qualifier.r name.r))
                    -.l
                data-row
    ~|  "comparing literal to column of different aura: ".
        "{<l>} {<name.r>} ".
        "{<-:(~(got bi:mip map-meta) qualifier.r name.r)>}"
        !!
  ::  column = literal
  ?:  &(?=(qualified-column:ast l) ?=(dime r))
    ~|  "column {<name.l>} does not exist"
    ?:  (types-match -:(~(got bi:mip map-meta) qualifier.l name.l) -.r)
      %+  bake  %+  cury
                    (cury (cury col-lit +:(~(got bi:mip map-meta) qualifier.l name.l)) +.r)
                    -.r
                data-row
    ~|  "comparing column to literal of different aura: {<name.l>} ".
        "{<-:(~(got bi:mip map-meta) qualifier.l name.l)>} {<r>}"
        !!
  ~|("datum-ops-qualified can't get here" !!)
::
++  datum-ops-qualified-eq
  |=  $:  l=datum:ast
          r=datum:ast
          map-meta=(mip:mip qualified-table @tas typ-addr)
          =qualifier-lookup
          lit-lit=$-([@ @ data-row] ?)
          col-col=$-([@ @ data-row] ?)
          col-lit=$-([@ @ data-row] ?)
          lit-col=$-([@ @ data-row] ?)
          ==
  ^-  $-(data-row ?)
  ::  literal = literal
  ?:  &(?=(dime l) ?=(dime r))
    ?:  (types-match -.l -.r)
      (bake (cury (cury lit-lit +.l) +.r) data-row)
    ~|("comparing column literals of different auras:  {<l>} {<r>}" !!)
  ::  column = column
  ?:  &(?=(qualified-column:ast l) ?=(qualified-column:ast r))
    ?:  %+  types-match
              ~|  "column {<name.l>} does not exist"
              -:(~(got bi:mip map-meta) qualifier.l name.l)
              ~|  "column {<name.r>} does not exist"
              -:(~(got bi:mip map-meta) qualifier.r name.r)
      %+  bake  %+  cury
                    (cury col-col +:(~(got bi:mip map-meta) qualifier.l name.l))
                    +:(~(got bi:mip map-meta) qualifier.r name.r)
                data-row
    ~|  "comparing columns of different auras: {<name.l>} ".
        "{<-:(~(got bi:mip map-meta) qualifier.l name.l)>} {<name.r>} ".
        "{<-:(~(got bi:mip map-meta) qualifier.r name.r)>}"
        !!
  ::  literal = column
  ?:  &(?=(dime l) ?=(qualified-column:ast r))
    ~|  "column {<name.r>} does not exist"
    ?:  (types-match -.l -:(~(got bi:mip map-meta) qualifier.r name.r))
      %+  bake  (cury (cury lit-col +.l) +:(~(got bi:mip map-meta) qualifier.r name.r))
                data-row
    ~|  "comparing literal to column of different aura: ".
        "{<l>} {<name.r>} ".
        "{<-:(~(got bi:mip map-meta) qualifier.r name.r)>}"
        !!
  ::  column = literal
  ?:  &(?=(qualified-column:ast l) ?=(dime r))
    ~|  "column {<name.l>} does not exist"
    ?:  (types-match -:(~(got bi:mip map-meta) qualifier.l name.l) -.r)
      %+  bake  (cury (cury col-lit +:(~(got bi:mip map-meta) qualifier.l name.l)) +.r)
                data-row
    ~|  "comparing column to literal of different aura: {<name.l>} ".
        "{<-:(~(got bi:mip map-meta) qualifier.l name.l)>} {<r>}"
        !!
  ~|("datum-ops-qualified-eq can't get here" !!)
::
++  datum-ops-unqualified
  |=  $:  l=datum:ast
          r=datum:ast
          map-meta=(map @tas typ-addr)
          lit-lit=$-([@ @ @ta data-row] ?)
          col-col=column-column
          col-lit=$-([@ @ @ta data-row] ?)
          lit-col=$-([@ @ @ta data-row] ?)
          ==
  ^-  $-(data-row ?)
  ::  literal = literal
  ?:  &(?=(dime l) ?=(dime r))
    ?:  (types-match -.l -.r)
      (bake (cury (cury (cury lit-lit +.l) +.r) -.l) data-row)
    ~|("comparing column literals of different auras: {<l>} {<r>}" !!)
  ::  column = column
  ?:  &(?=(qualified-column:ast l) ?=(qualified-column:ast r))
    ?:  %+  types-match  ~|  "column {<name.l>} does not exist"
                         -:(~(got by map-meta) name.l)
                         ~|  "column {<name.r>} does not exist"
                         -:(~(got by map-meta) name.r)
      %+  bake  %+  cury
                    %+  cury  (cury col-col +:(~(got by map-meta) name.l))
                              +:(~(got by map-meta) name.r)
                    -:(~(got by map-meta) name.l)
                data-row
    ~|  "comparing columns of different auras: {<name.l>} ".
        "{<-:(~(got by map-meta) name.l)>} {<name.r>} ".
        "{<-:(~(got by map-meta) name.r)>}"
        !!
  ?:  &(?=(unqualified-column:ast l) ?=(unqualified-column:ast r))
    ?:  %+  types-match  ~|  "column {<name.l>} does not exist"
                         -:(~(got by map-meta) name.l)
                         ~|  "column {<name.r>} does not exist"
                         -:(~(got by map-meta) name.r)
      %+  bake  %+  cury
                    %+  cury  (cury col-col +:(~(got by map-meta) name.l))
                              +:(~(got by map-meta) name.r)
                    -:(~(got by map-meta) name.l)
                data-row
    ~|  "comparing columns of different auras: {<name.l>} ".
        "{<-:(~(got by map-meta) name.l)>} {<name.r>} ".
        "{<-:(~(got by map-meta) name.r)>}"
        !!
  ::  literal = column
  ?:  &(?=(dime l) ?=(qualified-column:ast r))
    ~|  "column {<name.r>} does not exist"
    ?:  (types-match -.l -:(~(got by map-meta) name.r))
      %+  bake  %+  cury
                    (cury (cury lit-col +.l) +:(~(got by map-meta) name.r))
                    -.l
                data-row
    ~|  "comparing literal to column of different aura: {<l>} {<name.r>} ".
        "{<-:(~(got by map-meta) name.r)>}"
        !!
  ?:  &(?=(dime l) ?=(unqualified-column:ast r))
    ~|  "column {<name.r>} does not exist"
    ?:  (types-match -.l -:(~(got by map-meta) name.r))
      %+  bake  %+  cury
                    (cury (cury lit-col +.l) +:(~(got by map-meta) name.r))
                    -.l
                data-row
    ~|  "comparing literal to column of different aura: {<l>} {<name.r>} ".
        "{<-:(~(got by map-meta) name.r)>}"
        !!
  ::  column = literal
  ?:  &(?=(qualified-column:ast l) ?=(dime r))
    ~|  "column {<name.l>} does not exist"
    ?:  (types-match -:(~(got by map-meta) name.l) -.r)
      %+  bake  %+  cury
                    (cury (cury col-lit +:(~(got by map-meta) name.l)) +.r)
                    -.r
                data-row
    ~|  "comparing column to literal of different aura: {<name.l>} ".
        "{<-:(~(got by map-meta) name.l)>} {<r>}"
        !!
  ?:  &(?=(unqualified-column:ast l) ?=(dime r))
    ~|  "column {<name.l>} does not exist"
    ?:  (types-match -:(~(got by map-meta) name.l) -.r)
      %+  bake  %+  cury
                    (cury (cury col-lit +:(~(got by map-meta) name.l)) +.r)
                    -.r
                data-row
    ~|  "comparing column to literal of different aura: {<name.l>} ".
        "{<-:(~(got by map-meta) name.l)>} {<r>}"
        !!
  ::
  ~|("datum-ops-unqualified can't get here" !!)
::
++  datum-ops-unqualified-eq
  |=  $:  l=datum:ast
          r=datum:ast
          map-meta=(map @tas typ-addr)
          lit-lit=$-([@ @ data-row] ?)
          col-col=$-([@ @ data-row] ?)
          col-lit=$-([@ @ data-row] ?)
          lit-col=$-([@ @ data-row] ?)
          ==
  ^-  $-(data-row ?)
  ::  literal = literal
  ?:  &(?=(dime l) ?=(dime r))
    ?:  (types-match -.l -.r)
      (bake (cury (cury lit-lit +.l) +.r) data-row)
    ~|("comparing column literals of different auras: {<l>} {<r>}" !!)
  ::  column = column
  ?:  &(?=(qualified-column:ast l) ?=(qualified-column:ast r))
    ?:  %+  types-match  ~|  "column {<name.l>} does not exist"
                         -:(~(got by map-meta) name.l)
                         ~|  "column {<name.r>} does not exist"
                         -:(~(got by map-meta) name.r)
      %+  bake  %+  cury
                    (cury col-col +:(~(got by map-meta) name.l))
                    +:(~(got by map-meta) name.r)
                data-row
    ~|  "comparing columns of different auras: {<name.l>} ".
        "{<-:(~(got by map-meta) name.l)>} {<name.r>} ".
        "{<-:(~(got by map-meta) name.r)>}"
        !!
  ?:  &(?=(unqualified-column:ast l) ?=(unqualified-column:ast r))
    ?:  %+  types-match  ~|  "column {<name.l>} does not exist"
                         -:(~(got by map-meta) name.l)
                         ~|  "column {<name.r>} does not exist"
                         -:(~(got by map-meta) name.r)
      %+  bake  %+  cury
                    (cury col-col +:(~(got by map-meta) name.l))
                    +:(~(got by map-meta) name.r)
                data-row
    ~|  "comparing columns of different auras: {<name.l>} ".
        "{<-:(~(got by map-meta) name.l)>} {<name.r>} ".
        "{<-:(~(got by map-meta) name.r)>}"
        !!
  ::  literal = column
  ?:  &(?=(dime l) ?=(qualified-column:ast r))
    ~|  "column {<name.r>} does not exist"
    ?:  (types-match -.l -:(~(got by map-meta) name.r))
      %+  bake  (cury (cury lit-col +.l) +:(~(got by map-meta) name.r))
                data-row
    ~|  "comparing literal to column of different aura: {<l>} {<name.r>} ".
        "{<-:(~(got by map-meta) name.r)>}"
        !!
  ?:  &(?=(dime l) ?=(unqualified-column:ast r))
    ~|  "column {<name.r>} does not exist"
    ?:  (types-match -.l -:(~(got by map-meta) name.r))
      %+  bake  (cury (cury lit-col +.l) +:(~(got by map-meta) name.r))
                data-row
    ~|  "comparing literal to column of different aura: {<l>} {<name.r>} ".
        "{<-:(~(got by map-meta) name.r)>}"
        !!
  ::  column = literal
  ?:  &(?=(qualified-column:ast l) ?=(dime r))
    ~|  "column {<name.l>} does not exist"
    ?:  (types-match -:(~(got by map-meta) name.l) -.r)
      %+  bake  (cury (cury col-lit +:(~(got by map-meta) name.l)) +.r)
                data-row
    ~|  "comparing column to literal of different aura: {<name.l>} ".
        "{<-:(~(got by map-meta) name.l)>} {<r>}"
        !!
  ?:  &(?=(unqualified-column:ast l) ?=(dime r))
    ~|  "column {<name.l>} does not exist"
    ?:  (types-match -:(~(got by map-meta) name.l) -.r)
      %+  bake  (cury (cury col-lit +:(~(got by map-meta) name.l)) +.r)
                data-row
    ~|  "comparing column to literal of different aura: {<name.l>} ".
        "{<-:(~(got by map-meta) name.l)>} {<r>}"
        !!
  ::
  ~|("datum-ops-unqualified-eq can't get here" !!)
::
++  pred-inequality-op
  |=  [p=inequality-op l=datum:ast r=datum:ast =map-meta =qualifier-lookup]
  ^-  $-(data-row ?)
  ?-  p
    %neq
      ?:  ?=(%qualified-map-meta -.map-meta)
        %:  datum-ops-qualified-eq  l
                                    r
                                    +.map-meta
                                    qualifier-lookup
                                    neq-lit-lit
                                    neq-col-col
                                    neq-col-lit
                                    neq-lit-col
                                    ==
      %:  datum-ops-unqualified-eq  l
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
::
++  split-all
  ::  Splits a list into multiple lists, delimited by another list.
  ::    Examples
  ::      > (split-all "abcdefabhijkablmn" "ab")
  ::      ~[~ "cdef" "hijk" "lmn"]
  ::    Source
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
::  
++  types-match
  |=  [l=@ta r=@ta]
  ^-  ?
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
::  $binary-op:            ?(%eq inequality-op %equiv %not-equiv %in %not-in)
::
::  eq
::
++  eq-lit-col
  |=  [a=@ b=@ c=data-row]
  ^-  ?
  =/  x  .*(data.c [%0 b])
  =(a ?@(x x ;;(@ +.x)))
::
++  eq-col-lit
  |=  [a=@ b=@ c=data-row]
  ^-  ?
  =/  x  .*(data.c [%0 a])
  =(?@(x x ;;(@ +.x)) b)
::
++  eq-col-col
  |=  [a=@ b=@ c=data-row]
  ^-  ?
  =/  x  .*(data.c [%0 a])
  =/  y  .*(data.c [%0 b])
  ?@  x  =(x y)
  =(;;(@ +.x) ;;(@ +.y))
::
++  eq-lit-lit
  |=  [a=@ b=@ c=data-row]
  ^-  ?
  =(a b)
::
::  neq
::
++  neq-lit-col
  |=  [a=@ b=@ c=data-row]
  ^-  ?
  =/  x  .*(data.c [%0 b])
  ?!(=(a ?@(x x ;;(@ +.x))))
::
++  neq-col-lit
  |=  [a=@ b=@ c=data-row]
  ^-  ?
  =/  x  .*(data.c [%0 a])
  ?!(=(?@(x x ;;(@ +.x)) b))
::
++  neq-col-col
  |=  [a=@ b=@ c=data-row]
  ^-  ?
  =/  x  .*(data.c [%0 a])
  =/  y  .*(data.c [%0 b])
  ?@  x  ?!(=(x y))
  ?!(=(;;(@ +.x) ;;(@ +.y)))
::
++  neq-lit-lit
  |=  [a=@ b=@ c=data-row]
  ^-  ?
  ?!(=(a b))
::
::  gt
::
++  gt-lit-col
  |=  [a=@ b=@ typ=@ta c=data-row]
  ^-  ?
  =/  x  .*(data.c [%0 b])
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    ?:  =(a ?@(x x ;;(@ +.x)))  %.n
    (alpha ?@(x `@t`x `@t`;;(@ +.x)) `@t`a)
  (gth a ?@(x x ;;(@ +.x)))
::
++  gt-col-lit
  |=  [a=@ b=@ typ=@ta c=data-row]
  ^-  ?
  =/  x  .*(data.c [%0 a])
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    ?:  =(?@(x x ;;(@ +.x)) b)  %.n
    (alpha `@t`b ?@(x `@t`x `@t`;;(@ +.x)))
  (gth ?@(x x ;;(@ +.x)) b)
::
++  gt-col-col
  |=  [a=@ b=@ typ=@ta c=data-row]
  ^-  ?
  =/  x  .*(data.c [%0 a])
  =/  y  .*(data.c [%0 b])
  ?@  x
    ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
      ?:  =(x y)  %.n
      (alpha `@t`;;(@ y) `@t`x)
    (gth x ;;(@ +.y))
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    ?:  =(;;(@ +.x) ;;(@ +.y))  %.n
    (alpha ;;(@ +.y) ;;(@ +.x))
  (gth ;;(@ +.x) ;;(@ +.y))
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
  |=  [a=@ b=@ typ=@ta c=data-row]
  ^-  ?
  =/  x  .*(data.c [%0 b])
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    (alpha ?@(x `@t`x `@t`;;(@ +.x)) a)
  (gte a ?@(x x ;;(@ +.x)))
::
++  gte-col-lit
  |=  [a=@ b=@ typ=@ta c=data-row]
  ^-  ?
  =/  x  .*(data.c [%0 a])
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    (alpha b ?@(x `@t`x `@t`;;(@ +.x)))
  (gte ?@(x x ;;(@ +.x)) b)
::
++  gte-col-col
  |=  [a=@ b=@ typ=@ta c=data-row]
  ^-  ?
  =/  x  .*(data.c [%0 a])
  =/  y  .*(data.c [%0 b])
  ?@  x
    ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
      (alpha `@t`;;(@ y) `@t`x)
    (gte x ;;(@ y))
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    (alpha `@t`;;(@ +.y) `@t`;;(@ +.x))
  (gte ;;(@ +.x) ;;(@ +.y))
::
++  gte-lit-lit
  |=  [a=@ b=@ typ=@ta c=data-row]
  ^-  ?
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    (alpha `@t`b `@t`a)
  (gte a b)
::
::  lt
::
++  lt-lit-col
  |=  [a=@ b=@ typ=@ta c=data-row]
  ^-  ?
  =/  x  .*(data.c [%0 b])
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    ?:  =(a ?@(x x ;;(@ +.x)))  %.n
    (alpha `@t`a ?@(x `@t`x `@t`;;(@ +.x)))
  (lth a ?@(x x ;;(@ +.x)))
::
++  lt-col-lit
  |=  [a=@ b=@ typ=@ta c=data-row]
  ^-  ?
  =/  x  .*(data.c [%0 a])
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    ?:  =(?@(x x ;;(@ +.x)) b)  %.n
    (alpha ?@(x `@t`x `@t`;;(@ +.x)) `@t`b)
  (lth ?@(x x ;;(@ +.x)) b)
::
++  lt-col-col
  |=  [a=@ b=@ typ=@ta c=data-row]
  ^-  ?
  =/  x  .*(data.c [%0 a])
  =/  y  .*(data.c [%0 b])
  ?@  x
    ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
      ?:  =(x y)  %.n
      (alpha `@t`x `@t`;;(@ y))
    (lth x ;;(@ y))
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    ?:  =(;;(@ +.x) ;;(@ +.y))  %.n
    (alpha `@t`;;(@ +.x) `@t`;;(@ +.y))
  (lth ;;(@ +.x) ;;(@ +.y))
::
++  lt-lit-lit
  |=  [a=@ b=@ typ=@ta c=data-row]
  ^-  ?
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    ?:  =(a b)  %.n
    (alpha `@t`a `@t`b)
  (lth a b)
::
::  lte
::
++  lte-lit-col
  |=  [a=@ b=@ typ=@ta c=data-row]
  ^-  ?
  =/  x  .*(data.c [%0 b])
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    (alpha `@t`a ?@(x `@t`x `@t`;;(@ +.x)))
  (lte a ?@(x x ;;(@ +.x)))
::
++  lte-col-lit
  |=  [a=@ b=@ typ=@ta c=data-row]
  ^-  ?
  =/  x  .*(data.c [%0 a])
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    (alpha ?@(x `@t`x `@t`;;(@ +.x)) b)
  (lte ?@(x x ;;(@ +.x)) b)
::
++  lte-col-col
  |=  [a=@ b=@ typ=@ta c=data-row]
  ^-  ?
  =/  x  .*(data.c [%0 a])
  =/  y  .*(data.c [%0 b])
  ?@  x
    ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
      (alpha `@t`x `@t`;;(@ y))
    (lte x ;;(@ y))
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    (alpha `@t`;;(@ +.x) `@t`;;(@ +.y))
  (lte ;;(@ +.x) ;;(@ +.y))
::
++  lte-lit-lit
  |=  [a=@ b=@ typ=@ta c=data-row]
  ^-  ?
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    (alpha `@t`a `@t`b)
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
  |=  [a=@ b=(list @) c=data-row]
  ^-  ?
  =/  x  .*(data.c [%0 a])
  =/  val  ?@(x x ;;(@ +.x))
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
  |=  [a=@ b=(list @) c=data-row]
  ^-  ?
  =/  x  .*(data.c [%0 a])
  =/  val  ?@(x x ;;(@ +.x))
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
::  $conjunction:            ?(%and %or)
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
++  normalize-predicate
  ::  fail if column name available for multiple qualifiers
  |=  [p=predicate:ast =qualifier-lookup]
  ^-  predicate:ast
  |-
  ?~  p  ~
  p(n (normalize-leaf n.p qualifier-lookup), l $(p l.p), r $(p r.p))
::
++  normalize-leaf
  |=  [a=predicate-component:ast =qualifier-lookup]
  ^-  predicate-component:ast
  ?:  ?=(unqualified-column:ast a)
    ~|  "column {<name.a>} does not exist"
    ?:  =((lent (~(got by qualifier-lookup) name.a)) 1)
      :^  %qualified-column
          (normalize-qt-alias -:(~(got by qualifier-lookup) name.a))
          name.a
          alias.a
    ~|("undetermined qualifier for {<name.a>} in predicate" !!)
  ?:  ?=(qualified-column:ast a)
    :^  %qualified-column
        (normalize-qt-alias qualifier.a)
        name.a
        alias.a
  a
::
++  pred-unqualify-qualified
  ::  single table predicate must have unqualified-column
  |=  p=predicate:ast
  ^-  predicate:ast
  |-
  ?~  p  ~
  p(n (unqualify-leaf n.p), l $(p l.p), r $(p r.p))
::
++  unqualify-leaf
  |=  a=predicate-component:ast
  ^-  predicate-component:ast
  ?.  ?=(qualified-column:ast a)  a
  ::
  %:  unqualified-column:ast  %unqualified-column
                              name.a
                              alias.a
                              ==
--
