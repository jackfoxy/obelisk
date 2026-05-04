/-  *ast, *obelisk, *server-state-1
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
  ::        (delegates to prepare-binary-op)
  ::    - unary-op: NOT, EXISTS, NOT EXISTS (delegates to prepare-unary-op)
  ::    - conjunction: AND/OR (recursively combines left and right predicates)
  ::    - all-any-op: ALL/ANY (not yet implemented)
  ::
  |=  $:  p=predicate:ast
          =map-meta
          =qualifier-lookup
          =named-ctes
          =resolved-scalars
          ==
  ^-  $-(data-row ?)
  ?~  p  ~|("prepare-predicate can't get here 1" !!) 
  ?.  ?=(ops-and-conjs n.p)  ~|("prepare-predicate can't get here 2" !!)
  ?-  n.p
    ::
    ternary-op
      ?~  l.p  ~|("prepare-predicate can't get here 3" !!)
      ?~  r.p  ~|("prepare-predicate can't get here 4" !!)
      =/  ll=$-(data-row ?)  %:  prepare-binary-op  l.p
                                                 map-meta
                                                 qualifier-lookup
                                                 named-ctes
                                                 resolved-scalars
                                                 ==
      =/  rr=$-(data-row ?)  %:  prepare-binary-op  r.p
                                                 map-meta
                                                 qualifier-lookup
                                                 named-ctes
                                                 resolved-scalars
                                                 ==
      ?:  =(%between n.p)
        (bake (cury (cury and ll) rr) data-row)
      (bake (cury (cury and-not ll) rr) data-row)
    ::
    binary-op
      %:  prepare-binary-op  p
                             map-meta
                             qualifier-lookup
                             named-ctes
                             resolved-scalars
                             ==
    ::
    unary-op
      (prepare-unary-op p map-meta qualifier-lookup named-ctes resolved-scalars)
    ::
    all-any-op
      ~|("%all and %any not implemented" !!)
    ::
    conjunction
      ?~  l.p  ~|("prepare-predicate can't get here 5" !!)
      ?~  r.p  ~|("prepare-predicate can't get here 6" !!)
      =/  ll=$-(data-row ?)  %:  prepare-predicate  l.p
                                                    map-meta
                                                    qualifier-lookup
                                                    named-ctes
                                                    resolved-scalars
                                                    ==
      =/  rr=$-(data-row ?)  %:  prepare-predicate  r.p
                                                    map-meta
                                                    qualifier-lookup
                                                    named-ctes
                                                    resolved-scalars
                                                    ==
      ?:  =(%and n.p)
        (bake (cury (cury and ll) rr) data-row)
      (bake (cury (cury or ll) rr) data-row)
    ==
:: 
++  prepare-unary-op
  |=  $:  p=predicate:ast
          =map-meta
          =qualifier-lookup
          =named-ctes
          =resolved-scalars
          ==
  ^-  $-(data-row ?)
  ?~  p  ~|("prepare-unary-op can't get here" !!)
  ?~  l.p  ~|("prepare-unary-op can't get here" !!)
  ?.  ?=(unary-op n.p)  ~|("prepare-unary-op can't get here" !!)
  ::
  ?-  n.p
    %not
    :: this doesn't handle a qualified/unqualified column as argument
      =/  ll=$-(data-row ?)  %:  prepare-predicate  l.p
                                                    map-meta
                                                    qualifier-lookup
                                                    named-ctes
                                                    resolved-scalars
                                                    ==
      (bake (cury not ll) data-row)
    %exists
      ~|("%exists not implemented" !!)
    %not-exists
      ~|("%not-exists not implemented" !!)
    ==
:: 
++  prepare-binary-op
  |=  $:  p=predicate:ast
          =map-meta
          =qualifier-lookup
          =named-ctes
          =resolved-scalars
          ==
  ^-  $-(data-row ?)
  ?~  p                  ~|("prepare-binary-op can't get here" !!)
  ?.  ?=(binary-op n.p)  ~|("prepare-binary-op can't get here" !!)
  ?~  l.p                ~|("prepare-binary-op can't get here" !!)
  ?~  r.p                ~|("prepare-binary-op can't get here" !!)
  ::
  ?-  n.p
    %eq
      =/  l=datum:ast  (get-datum n.l.p)
      =/  r=datum:ast  (get-datum n.r.p)
      %:  apply-datum-op  l
                          r
                          map-meta
                          qualifier-lookup
                          named-ctes
                          resolved-scalars
                          eq-lit-lit
                          eq-col-col
                          eq-col-lit
                          eq-lit-col
                          ==
    inequality-op
      =/  l=datum:ast  (get-datum n.l.p)
      =/  r=datum:ast  (get-datum n.r.p)
      %:  prepare-inequality-op  n.p
                                 l
                                 r
                                 map-meta
                                 qualifier-lookup
                                 named-ctes
                                 resolved-scalars
                                 ==
    %equiv
      :: to do: the commented code tests for existence in the wrong place
      ::        it needs to take place at run time and row-by-row
      ::    fix when outer joins implemented 
      ::=/  l=datum:ast  ?:  ?=(unqualified-column:ast n.l.p)  n.l.p
      ::             ?:  ?=(qualified-column:ast n.l.p)  n.l.p
      ::             ?:  ?=(scalar-name:ast n.l.p)  n.l.p
      ::             ?:  ?=(dime n.l.p)  n.l.p
      ::             ~|("prepare-binary-op can't get here" !!)
      ::=/  r=datum:ast  ?:  ?=(unqualified-column:ast n.r.p)   n.r.p
      ::             ?:  ?=(qualified-column:ast n.r.p)   n.r.p
      ::             ?:  ?=(scalar-name:ast n.r.p)   n.r.p
      ::             ?:  ?=(dime n.r.p)   n.r.p
      ::             ~|("prepare-binary-op can't get here" !!::)
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
      ::~|("prepare-binary-op can't get here" !!)
      ~|("%equiv not implemented" !!)
    %not-equiv
      ~|("%not-equiv not implemented" !!)
    %in
      %:  prepare-common-list  p
                               map-meta
                               named-ctes
                               resolved-scalars
                               in-col-list
                               in-lit-list
                               ==
    %not-in
      %:  prepare-common-list  p
                               map-meta
                               named-ctes
                               resolved-scalars
                               not-in-col-list
                               not-in-lit-list
                               ==
    ==
::
++  prepare-common-list
  |=  $:  p=predicate:ast
          =map-meta
          =named-ctes
          =resolved-scalars
          list-pred=$-([@ @ta (list @) =data-row] ?)
          lit-list-pred=$-([@ @ta (list @) =data-row] ?)
          ==
  ^-  $-(data-row ?)
  ?~  p                  ~|("prepare-common-list can't get here 1" !!)
  ?~  l.p                ~|("prepare-common-list can't get here 2" !!)
  ?~  r.p                ~|("prepare-common-list can't get here 3" !!)
  ::  typ derived from left side only;
  ::  computed before in-list so branches can use it
  =/  typ
    ?:  ?=(scalar-name:ast n.l.p)
      =/  rs  (resolve-scalar-name n.l.p resolved-scalars)
      (resolved-scalar-type rs)
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
    ?:  ?=(cte-column:ast n.l.p)
      =/  cte-fr  (~(got by named-ctes) cte.n.l.p)
      =/  ta=typ-addr
        %+  ~(got bi:mip +.map-meta.cte-fr)  [%cte-name cte.n.l.p ~]  name.n.l.p
      type.ta
    ~|("prepare-common-list can't get here 5" !!)
  =/  in-list=(list @)
    ?:  ?=(cte-column:ast n.r.p)
      =/  cte-fr  (~(got by named-ctes) cte.n.r.p)
      ?~  set-tables.cte-fr
        ~|("prepare-common-list: empty cte set-tables" !!)
      =/  cte-st  i.set-tables.cte-fr
      =/  ta=typ-addr
        %+  ~(got bi:mip +.map-meta.cte-fr)  [%cte-name cte.n.r.p ~]  name.n.r.p
      ?.  (types-match typ type.ta)
        ~|  "IN cte-column type {<type.ta>} ".
            "doesn't match left side type {<typ>}"
            !!
      =/  rows=(list data-row)  ?~  joined-rows.cte-st  indexed-rows.cte-st
                                joined-rows.cte-st
      %~  tap  in  %-  silt  %+  turn  rows
                                       |=  row=data-row
                                       =/  x  .*(data.row [%0 addr.ta])
                                       ?@(x x ;;(@ +.x))
    =/  r=value-literals  ?:  ?=(value-literals n.r.p)  n.r.p
                          ~|("prepare-common-list can't get here 4" !!)
    =/  raw=(list @)
      %+  turn  (split-all (trip `@t`q.r) ";")
                |=(a=tape (rash (crip a) dem))
    ?.  (types-match typ p.r)
      ~|("type of IN list incorrect, should be {<typ>}" !!)
    raw
  ::  cte-column on left: resolve single scalar (requires 1-row cte),
  ::  check against list
  ?:  ?=(cte-column:ast n.l.p)
    =/  dl=dime  (resolve-cte-column n.l.p named-ctes)
    (bake (cury (cury (cury lit-list-pred q.dl) typ) in-list) data-row)
  ?:  ?&  ?=(unqualified-column:ast n.l.p)
          ?=(%unqualified-map-meta -.map-meta)
          ==
    %+  bake
          %+  cury
                (cury (cury list-pred +:(~(got by +.map-meta) name.n.l.p)) typ)
                in-list
          data-row
  ?:  ?&  ?=(qualified-column:ast n.l.p)
          ?=(%qualified-map-meta -.map-meta)
          ==
    %+  bake
          %+  cury
              %+  cury
                  %+  cury
                        list-pred
                        +:(~(got bi:mip +.map-meta) qualifier.n.l.p name.n.l.p)
                  typ
              in-list
          data-row
  ?:  ?&  ?=(qualified-column:ast n.l.p)
          ?=(%unqualified-map-meta -.map-meta)
          ==
    %+  bake
          %+  cury
                (cury (cury list-pred +:(~(got by +.map-meta) name.n.l.p)) typ)
                in-list
          data-row
  ?:  ?=(scalar-name:ast n.l.p)
    =/  rs  (resolve-scalar-name n.l.p resolved-scalars)
    ?:  ?=(dime rs)
      (bake (cury (cury (cury lit-list-pred +.rs) typ) in-list) data-row)
    |=  =data-row
    ^-  ?
    =/  dl=dime  (apply-resolved-scalar rs data-row)
    (lit-list-pred q.dl typ in-list data-row)
  ?:  ?=(dime n.l.p)
    (bake (cury (cury (cury lit-list-pred +.n.l.p) typ) in-list) data-row)
  ~|("prepare-common-list can't get here 6" !!)
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
++  prepare-qualified
  |=  $:  l=datum:ast
          r=datum:ast
          map-meta=(mip:mip qualifier @tas typ-addr)
          =qualifier-lookup
          =named-ctes
          =resolved-scalars
          lit-lit=$-([@ @ @ta] ?)
          col-col=column-column
          col-lit=$-([@ @ @ta data-row] ?)
          lit-col=$-([@ @ @ta data-row] ?)
          ==
  ^-  $-(data-row ?)
  =/  l-scalar=(unit resolved-scalar)
    ?:  ?=(scalar-name:ast l)
      (some (resolve-scalar-name l resolved-scalars))
    ~
  =/  r-scalar=(unit resolved-scalar)
    ?:  ?=(scalar-name:ast r)
      (some (resolve-scalar-name r resolved-scalars))
    ~
  ?:  ?&  ?=(^ l-scalar)
          ?=(dime u.l-scalar)
          ==
    $(l ;;(datum:ast u.l-scalar))
  ?:  ?&  ?=(^ r-scalar)
          ?=(dime u.r-scalar)
          ==
    $(r ;;(datum:ast u.r-scalar))
  ::  scalar = scalar
  ?:  &(?=(^ l-scalar) ?=(^ r-scalar))
    =/  ln=@tas  name:;;(scalar-name:ast l)
    =/  rn=@tas  name:;;(scalar-name:ast r)
    =/  lt  (resolved-scalar-type u.l-scalar)
    =/  rt  (resolved-scalar-type u.r-scalar)
    ?:  (types-match lt rt)
      |=  c=data-row
      =/  dl=dime  (apply-resolved-scalar u.l-scalar c)
      =/  dr=dime  (apply-resolved-scalar u.r-scalar c)
      (lit-lit q.dl q.dr lt)
    ~|  "comparing scalars of different auras: {<ln>} type={<lt>} ".
        "{<rn>} type={<rt>}"
        !!
  ::  literal = literal
  ?:  ?&  ?=(dime l)
          ?=(dime r)
          ?!(?=(scalar-name:ast l))
          ?!(?=(scalar-name:ast r))
          ==
    ?:  (types-match -.l -.r)
      |=(c=data-row (lit-lit +.l +.r -.l))
    ~|("comparing column literals of different auras:  {<l>} {<r>}" !!)
  ::  column = column
  ?:  &(?=(qualified-column:ast l) ?=(qualified-column:ast r))
    ?:  %+  types-match
              ~|  "column {<name.l>} does not exist"
              -:(~(got bi:mip map-meta) qualifier.l name.l)
              ~|  "column {<name.r>} does not exist"
              -:(~(got bi:mip map-meta) qualifier.r name.r)
      %+  bake  %+  cury
                      %+  cury
                            %+  cury
                                  col-col
                                  +:(~(got bi:mip map-meta) qualifier.l name.l)
                            +:(~(got bi:mip map-meta) qualifier.r name.r)
                      -:(~(got bi:mip map-meta) qualifier.l name.l)
                data-row
    ~|  "comparing columns of different auras: {<name.l>} ".
        "{<-:(~(got bi:mip map-meta) qualifier.l name.l)>} {<name.r>} ".
        "{<-:(~(got bi:mip map-meta) qualifier.r name.r)>}"
        !!
  ::  literal = column
  ?:  ?&  ?=(dime l)
          ?!(?=(scalar-name:ast l))
          ?=(qualified-column:ast r)
          ==
    ~|  "column {<name.r>} does not exist"
    ?:  (types-match -.l -:(~(got bi:mip map-meta) qualifier.r name.r))
      %+  bake  %+  cury
                      %+  cury  (cury lit-col +.l)
                                +:(~(got bi:mip map-meta) qualifier.r name.r)
                      -.l
                data-row
    ~|  "comparing literal to column of different aura: ".
        "{<l>} {<name.r>} ".
        "{<-:(~(got bi:mip map-meta) qualifier.r name.r)>}"
        !!
  ::  column = literal
  ?:  ?&  ?=(qualified-column:ast l)
          ?=(dime r)
          ?!(?=(scalar-name:ast r))
          ==
    ~|  "column {<name.l>} does not exist"
    ?:  (types-match -:(~(got bi:mip map-meta) qualifier.l name.l) -.r)
      %+  bake  %+  cury
                      %+  cury
                            %+  cury
                                  col-lit
                                  +:(~(got bi:mip map-meta) qualifier.l name.l)
                            +.r
                      -.r
                data-row
    ~|  "comparing column to literal of different aura: {<name.l>} ".
        "{<-:(~(got bi:mip map-meta) qualifier.l name.l)>} {<r>}"
        !!
  ::  scalar = literal
  ?:  ?&  ?=(^ l-scalar)
          ?=(dime r)
          ==
    =/  ln=@tas  name:;;(scalar-name:ast l)
    =/  lt  (resolved-scalar-type u.l-scalar)
    ?:  (types-match lt -.r)
      |=  c=data-row
      =/  dl=dime  (apply-resolved-scalar u.l-scalar c)
      (lit-lit q.dl +.r lt)
    ~|  "comparing scalar to literal of different aura: {<ln>} ".
        "type={<lt>} {<r>}"
        !!
  ::  literal = scalar
  ?:  ?&  ?=(dime l)
          ?=(^ r-scalar)
          ==
    =/  rn=@tas  name:;;(scalar-name:ast r)
    =/  rt  (resolved-scalar-type u.r-scalar)
    ?:  (types-match -.l rt)
      |=  c=data-row
      =/  dr=dime  (apply-resolved-scalar u.r-scalar c)
      (lit-lit +.l q.dr -.l)
    ~|  "comparing literal to scalar of different aura: {<l>} {<rn>} ".
        "type={<rt>}"
        !!
  ::  scalar = column
  ?:  ?&  ?=(^ l-scalar)
          ?=(qualified-column:ast r)
          ==
    =/  ln=@tas  name:;;(scalar-name:ast l)
    =/  lt  (resolved-scalar-type u.l-scalar)
    =/  rt  ~|  "column {<name.r>} does not exist"
              -:(~(got bi:mip map-meta) qualifier.r name.r)
    ?:  (types-match lt rt)
      |=  c=data-row
      =/  dl=dime  (apply-resolved-scalar u.l-scalar c)
      (lit-col q.dl +:(~(got bi:mip map-meta) qualifier.r name.r) lt c)
    ~|  "comparing scalar to column of different aura: {<ln>} ".
        "type={<lt>} {<name.r>} {<rt>}"
        !!
  ::  column = scalar
  ?:  ?&  ?=(qualified-column:ast l)
          ?=(^ r-scalar)
          ==
    =/  rn=@tas  name:;;(scalar-name:ast r)
    =/  rt  (resolved-scalar-type u.r-scalar)
    =/  lt  ~|  "column {<name.l>} does not exist"
              -:(~(got bi:mip map-meta) qualifier.l name.l)
    ?:  (types-match lt rt)
      |=  c=data-row
      =/  dr=dime  (apply-resolved-scalar u.r-scalar c)
      (col-lit +:(~(got bi:mip map-meta) qualifier.l name.l) q.dr rt c)
    ~|  "comparing column to scalar of different aura: {<name.l>} ".
        "{<lt>} {<rn>} type={<rt>}"
        !!
  ::  cte-column = cte-column
  ?:  &(?=(cte-column:ast l) ?=(cte-column:ast r))
    =/  dl=dime  (resolve-cte-column l named-ctes)
    =/  dr=dime  (resolve-cte-column r named-ctes)
    ?.  (types-match p.dl p.dr)
      ~|("comparing cte-columns of different auras: {<name.l>} {<name.r>}" !!)
    |=(c=data-row (lit-lit q.dl q.dr p.dl))
  ::  cte-column = literal
  ?:  &(?=(cte-column:ast l) ?=(dime r))
    =/  dl=dime  (resolve-cte-column l named-ctes)
    ?.  (types-match p.dl -.r)
      ~|  "comparing cte-column to literal of different aura: {<name.l>} {<r>}"
          !!
    |=(c=data-row (lit-lit q.dl +.r p.dl))
  ::  literal = cte-column
  ?:  &(?=(dime l) ?=(cte-column:ast r))
    =/  dr=dime  (resolve-cte-column r named-ctes)
    ?.  (types-match -.l p.dr)
      ~|  "comparing literal to cte-column of different aura: {<l>} {<name.r>}"
          !!
    |=(c=data-row (lit-lit +.l q.dr -.l))
  ::  cte-column = column
  ?:  &(?=(cte-column:ast l) ?=(qualified-column:ast r))
    =/  dl=dime  (resolve-cte-column l named-ctes)
    ~|  "column {<name.r>} does not exist"
    ?:  (types-match p.dl -:(~(got bi:mip map-meta) qualifier.r name.r))
      %+  bake  %+  cury
                      %+  cury  (cury lit-col q.dl)
                                +:(~(got bi:mip map-meta) qualifier.r name.r)
                      p.dl
                data-row
    ~|  "comparing cte-column to column of different aura: ".
        "{<name.l>} {<name.r>}"
        !!
  ::  column = cte-column
  ?:  &(?=(qualified-column:ast l) ?=(cte-column:ast r))
    =/  dr=dime  (resolve-cte-column r named-ctes)
    ~|  "column {<name.l>} does not exist"
    ?:  (types-match -:(~(got bi:mip map-meta) qualifier.l name.l) p.dr)
      %+  bake  %+  cury
                      %+  cury
                            %+  cury
                                  col-lit
                                  +:(~(got bi:mip map-meta) qualifier.l name.l)
                            q.dr
                      -:(~(got bi:mip map-meta) qualifier.l name.l)
                data-row
    ~|  "comparing column to cte-column of different aura: ".
        "{<name.l>} {<name.r>}"
        !!
  ::  scalar = cte-column
  ?:  ?&  ?=(^ l-scalar)
          ?=(cte-column:ast r)
          ==
    =/  ln=@tas  name:;;(scalar-name:ast l)
    =/  lt  (resolved-scalar-type u.l-scalar)
    =/  dr=dime  (resolve-cte-column r named-ctes)
    ?:  (types-match lt p.dr)
      |=  c=data-row
      =/  dl=dime  (apply-resolved-scalar u.l-scalar c)
      (lit-lit q.dl q.dr lt)
    ~|  "comparing scalar to cte-column of different aura: {<ln>} ".
        "type={<lt>} {<name.r>}"
        !!
  ::  cte-column = scalar
  ?:  ?&  ?=(cte-column:ast l)
          ?=(^ r-scalar)
          ==
    =/  rn=@tas  name:;;(scalar-name:ast r)
    =/  dl=dime  (resolve-cte-column l named-ctes)
    =/  rt  (resolved-scalar-type u.r-scalar)
    ?:  (types-match p.dl rt)
      |=  c=data-row
      =/  dr=dime  (apply-resolved-scalar u.r-scalar c)
      (lit-lit q.dl q.dr p.dl)
    ~|  "comparing cte-column to scalar of different aura: {<name.l>} ".
        "{<rn>} type={<rt>}"
        !!
  ~|("prepare-qualified can't get here" !!)
::
++  col-name
  ::  extract name from either qualified or unqualified column
  |=  d=datum:ast
  ^-  @tas
  ?:  ?=(qualified-column:ast d)    name.d
  ?:  ?=(unqualified-column:ast d)  name.d
  ?:  ?=(cte-column:ast d)          name.d
  ~|("col-name: not a column" !!)
::
++  get-datum
  ::  cast a predicate-component to datum:ast
  |=  c=predicate-component:ast
  ^-  datum:ast
  ?:  ?=(unqualified-column:ast c)  c
  ?:  ?=(qualified-column:ast c)    c
  ?:  ?=(cte-column:ast c)          c
  ?:  ?=(scalar-name:ast c)         c
  ?:  ?=(dime c)                    c
  ~|("get-datum: not a datum" !!)
::
++  resolve-cte-column
  ::  extract a single-row CTE column value as a dime
  |=  [col=cte-column:ast =named-ctes]
  ^-  dime
  =/  cte-fr  (~(got by named-ctes) cte.col)
  ?~  set-tables.cte-fr
    ~|("resolve-cte-column: empty set-tables" !!)
  =/  cte-st  i.set-tables.cte-fr
  ?.  =(1 rowcount.cte-st)
    ~|("cte-column predicate requires exactly 1 row in cte {<cte.col>}" !!)
  =/  ta=typ-addr   %+  ~(got bi:mip +.map-meta.cte-fr)  [%cte-name cte.col ~]
                                                         name.col
  =/  row=data-row  ?~  joined-rows.cte-st
                      ?~  indexed-rows.cte-st
                        ~|("resolve-cte-column: no rows in cte {<cte.col>}" !!)
                      i.indexed-rows.cte-st
                    i.joined-rows.cte-st
  =/  x  .*(data.row [%0 addr.ta])
  =/  val=@  ?@(x x ;;(@ +.x))
  [type.ta val]
::
++  resolve-scalar-name
  |=  [s=scalar-name:ast =resolved-scalars]
  ^-  resolved-scalar
  ~|  "scalar {<name.s>} not found"
      (~(got by resolved-scalars) name.s)
::
++  resolved-scalar-type
  |=  rs=resolved-scalar
  ^-  @ta
  ?:  ?=(dime rs)
    -.rs
  type.rs
::
++  apply-resolved-scalar
  |=  [=resolved-scalar =data-row]
  ^-  dime
  ?:  ?=(dime resolved-scalar)
    resolved-scalar
  (f.resolved-scalar data-row)
::
++  prepare-unqualified
  |=  $:  l=datum:ast
          r=datum:ast
          map-meta=(map @tas typ-addr)
          =named-ctes
          =resolved-scalars
          lit-lit=$-([@ @ @ta] ?)
          col-col=column-column
          col-lit=$-([@ @ @ta data-row] ?)
          lit-col=$-([@ @ @ta data-row] ?)
          ==
  ^-  $-(data-row ?)
  =/  l-scalar=(unit resolved-scalar)
    ?:  ?=(scalar-name:ast l)
      (some (resolve-scalar-name l resolved-scalars))
    ~
  =/  r-scalar=(unit resolved-scalar)
    ?:  ?=(scalar-name:ast r)
      (some (resolve-scalar-name r resolved-scalars))
    ~
  ?:  ?&  ?=(^ l-scalar)
          ?=(dime u.l-scalar)
          ==
    $(l ;;(datum:ast u.l-scalar))
  ?:  ?&  ?=(^ r-scalar)
          ?=(dime u.r-scalar)
          ==
    $(r ;;(datum:ast u.r-scalar))
  ::  scalar = scalar
  ?:  &(?=(^ l-scalar) ?=(^ r-scalar))
    =/  ln=@tas  name:;;(scalar-name:ast l)
    =/  rn=@tas  name:;;(scalar-name:ast r)
    =/  lt  (resolved-scalar-type u.l-scalar)
    =/  rt  (resolved-scalar-type u.r-scalar)
    ?:  (types-match lt rt)
      |=  c=data-row
      =/  dl=dime  (apply-resolved-scalar u.l-scalar c)
      =/  dr=dime  (apply-resolved-scalar u.r-scalar c)
      (lit-lit q.dl q.dr lt)
    ~|  "comparing scalars of different auras: {<ln>} type={<lt>} ".
        "{<rn>} type={<rt>}"
        !!
  ::  literal = literal
  ?:  ?&  ?=(dime l)
          ?=(dime r)
          ?!(?=(scalar-name:ast l))
          ?!(?=(scalar-name:ast r))
          ==
    ?:  (types-match -.l -.r)
      |=(c=data-row (lit-lit +.l +.r -.l))
    ~|("comparing column literals of different auras: {<l>} {<r>}" !!)
  ::  column = column
  ?:  ?&  ?|(?=(qualified-column:ast l) ?=(unqualified-column:ast l))
          ?|(?=(qualified-column:ast r) ?=(unqualified-column:ast r))
          ==
    =/  ln  (col-name l)
    =/  rn  (col-name r)
    ?:  %+  types-match  ~|  "column {<ln>} does not exist"
                         -:(~(got by map-meta) ln)
                         ~|  "column {<rn>} does not exist"
                         -:(~(got by map-meta) rn)
      %+  bake  %+  cury
                    %+  cury  (cury col-col +:(~(got by map-meta) ln))
                              +:(~(got by map-meta) rn)
                    -:(~(got by map-meta) ln)
                data-row
    ~|  "comparing columns of different auras: {<ln>} ".
        "{<-:(~(got by map-meta) ln)>} {<rn>} ".
        "{<-:(~(got by map-meta) rn)>}"
        !!
  ::  literal = column
  ?:  ?&  ?=(dime l)
          ?!(?=(scalar-name:ast l))
          ?|(?=(qualified-column:ast r) ?=(unqualified-column:ast r))
          ==
    =/  rn  (col-name r)
    ~|  "column {<rn>} does not exist"
    ?:  (types-match -.l -:(~(got by map-meta) rn))
      %+  bake  %+  cury
                    (cury (cury lit-col +.l) +:(~(got by map-meta) rn))
                    -.l
                data-row
    ~|  "comparing literal to column of different aura: {<l>} {<rn>} ".
        "{<-:(~(got by map-meta) rn)>}"
        !!
  ::  column = literal
  ?:  ?&  ?|(?=(qualified-column:ast l) ?=(unqualified-column:ast l))
          ?=(dime r)
          ?!(?=(scalar-name:ast r))
          ==
    =/  ln  (col-name l)
    ~|  "column {<ln>} does not exist"
    ?:  (types-match -:(~(got by map-meta) ln) -.r)
      %+  bake  %+  cury
                    (cury (cury col-lit +:(~(got by map-meta) ln)) +.r)
                    -.r
                data-row
    ~|  "comparing column to literal of different aura: {<ln>} ".
        "{<-:(~(got by map-meta) ln)>} {<r>}"
        !!
  ::  scalar = literal
  ?:  ?&  ?=(^ l-scalar)
          ?=(dime r)
          ==
    =/  ln=@tas  name:;;(scalar-name:ast l)
    =/  lt  (resolved-scalar-type u.l-scalar)
    ?:  (types-match lt -.r)
      |=  c=data-row
      =/  dl=dime  (apply-resolved-scalar u.l-scalar c)
      (lit-lit q.dl +.r lt)
    ~|  "comparing scalar to literal of different aura: {<ln>} ".
        "type={<lt>} {<r>}"
        !!
  ::  literal = scalar
  ?:  ?&  ?=(dime l)
          ?=(^ r-scalar)
          ==
    =/  rn=@tas  name:;;(scalar-name:ast r)
    =/  rt  (resolved-scalar-type u.r-scalar)
    ?:  (types-match -.l rt)
      |=  c=data-row
      =/  dr=dime  (apply-resolved-scalar u.r-scalar c)
      (lit-lit +.l q.dr -.l)
    ~|  "comparing literal to scalar of different aura: {<l>} {<rn>} ".
        "type={<rt>}"
        !!
  ::  scalar = column
  ?:  ?&  ?=(^ l-scalar)
          ?|(?=(qualified-column:ast r) ?=(unqualified-column:ast r))
          ==
    =/  ln=@tas  name:;;(scalar-name:ast l)
    =/  lt  (resolved-scalar-type u.l-scalar)
    =/  rn  (col-name r)
    ~|  "column {<rn>} does not exist"
    ?:  (types-match lt -:(~(got by map-meta) rn))
      |=  c=data-row
      =/  dl=dime  (apply-resolved-scalar u.l-scalar c)
      (lit-col q.dl +:(~(got by map-meta) rn) lt c)
    ~|  "comparing scalar to column of different aura: {<ln>} ".
        "type={<lt>} {<rn>} {<-:(~(got by map-meta) rn)>}"
        !!
  ::  column = scalar
  ?:  ?&  ?|(?=(qualified-column:ast l) ?=(unqualified-column:ast l))
          ?=(^ r-scalar)
          ==
    =/  rn=@tas  name:;;(scalar-name:ast r)
    =/  rt  (resolved-scalar-type u.r-scalar)
    =/  ln  (col-name l)
    ~|  "column {<ln>} does not exist"
    ?:  (types-match -:(~(got by map-meta) ln) rt)
      |=  c=data-row
      =/  dr=dime  (apply-resolved-scalar u.r-scalar c)
      (col-lit +:(~(got by map-meta) ln) q.dr rt c)
    ~|  "comparing column to scalar of different aura: {<ln>} ".
        "{<-:(~(got by map-meta) ln)>} {<rn>} type={<rt>}"
        !!
  ::
  ::  cte-column = cte-column
  ?:  &(?=(cte-column:ast l) ?=(cte-column:ast r))
    =/  dl=dime  (resolve-cte-column l named-ctes)
    =/  dr=dime  (resolve-cte-column r named-ctes)
    ?.  (types-match p.dl p.dr)
      ~|("comparing cte-columns of different auras: {<name.l>} {<name.r>}" !!)
    |=(c=data-row (lit-lit q.dl q.dr p.dl))
  ::  cte-column = literal
  ?:  &(?=(cte-column:ast l) ?=(dime r))
    =/  dl=dime  (resolve-cte-column l named-ctes)
    ?.  (types-match p.dl -.r)
      ~|  "comparing cte-column to literal of different aura: {<name.l>} {<r>}"
          !!
    |=(c=data-row (lit-lit q.dl +.r p.dl))
  ::  literal = cte-column
  ?:  &(?=(dime l) ?=(cte-column:ast r))
    =/  dr=dime  (resolve-cte-column r named-ctes)
    ?.  (types-match -.l p.dr)
      ~|  "comparing literal to cte-column of different aura: {<l>} {<name.r>}"
          !!
    |=(c=data-row (lit-lit +.l q.dr -.l))
  ::  cte-column = column
  ?:  ?&  ?=(cte-column:ast l)
          ?|(?=(qualified-column:ast r) ?=(unqualified-column:ast r))
          ==
    =/  dl=dime  (resolve-cte-column l named-ctes)
    =/  rn  (col-name r)
    ~|  "column {<rn>} does not exist"
    ?:  (types-match p.dl -:(~(got by map-meta) rn))
      %+  bake  %+  cury
                    (cury (cury lit-col q.dl) +:(~(got by map-meta) rn))
                    p.dl
                data-row
    ~|("comparing cte-column to column of different aura: {<name.l>} {<rn>}" !!)
  ::  column = cte-column
  ?:  ?&  ?|(?=(qualified-column:ast l) ?=(unqualified-column:ast l))
          ?=(cte-column:ast r)
          ==
    =/  dr=dime  (resolve-cte-column r named-ctes)
    =/  ln  (col-name l)
    ~|  "column {<ln>} does not exist"
    ?:  (types-match -:(~(got by map-meta) ln) p.dr)
      %+  bake  %+  cury
                    (cury (cury col-lit +:(~(got by map-meta) ln)) q.dr)
                    -:(~(got by map-meta) ln)
                data-row
    ~|("comparing column to cte-column of different aura: {<ln>} {<name.r>}" !!)
  ::  scalar = cte-column
  ?:  ?&  ?=(^ l-scalar)
          ?=(cte-column:ast r)
          ==
    =/  ln=@tas  name:;;(scalar-name:ast l)
    =/  lt  (resolved-scalar-type u.l-scalar)
    =/  dr=dime  (resolve-cte-column r named-ctes)
    ?:  (types-match lt p.dr)
      |=  c=data-row
      =/  dl=dime  (apply-resolved-scalar u.l-scalar c)
      (lit-lit q.dl q.dr lt)
    ~|  "comparing scalar to cte-column of different aura: {<ln>} ".
        "type={<lt>} {<name.r>}"
        !!
  ::  cte-column = scalar
  ?:  ?&  ?=(cte-column:ast l)
          ?=(^ r-scalar)
          ==
    =/  rn=@tas  name:;;(scalar-name:ast r)
    =/  dl=dime  (resolve-cte-column l named-ctes)
    =/  rt  (resolved-scalar-type u.r-scalar)
    ?:  (types-match p.dl rt)
      |=  c=data-row
      =/  dr=dime  (apply-resolved-scalar u.r-scalar c)
      (lit-lit q.dl q.dr p.dl)
    ~|  "comparing cte-column to scalar of different aura: {<name.l>} ".
        "{<rn>} type={<rt>}"
        !!
  ~|("prepare-unqualified can't get here" !!)
::
++  apply-datum-op
  ::  dispatch to prepare-qualified 
  ::  or prepare-unqualified based on map-meta tag
  |=  $:  l=datum:ast
          r=datum:ast
          =map-meta
          =qualifier-lookup
          =named-ctes
          =resolved-scalars
          lit-lit=$-([@ @ @ta] ?)
          col-col=column-column
          col-lit=$-([@ @ @ta data-row] ?)
          lit-col=$-([@ @ @ta data-row] ?)
          ==
  ^-  $-(data-row ?)
  ?:  ?=(%qualified-map-meta -.map-meta)
    %:  prepare-qualified  l
                           r
                           +.map-meta
                           qualifier-lookup
                           named-ctes
                           resolved-scalars
                           lit-lit
                           col-col
                           col-lit
                           lit-col
                           ==
  %:  prepare-unqualified  l
                           r
                           +.map-meta
                           named-ctes
                           resolved-scalars
                           lit-lit
                           col-col
                           col-lit
                           lit-col
                           ==
::
++  prepare-inequality-op
  |=  $:  p=inequality-op
          l=datum:ast
          r=datum:ast
          =map-meta
          =qualifier-lookup
          =named-ctes
          =resolved-scalars
          ==
  ^-  $-(data-row ?)
  ?-  p
    %neq
      %:  apply-datum-op  l
                          r
                          map-meta
                          qualifier-lookup
                          named-ctes
                          resolved-scalars
                          neq-lit-lit
                          neq-col-col
                          neq-col-lit
                          neq-lit-col
                          ==
    %gt
      %:  apply-datum-op  l
                          r
                          map-meta
                          qualifier-lookup
                          named-ctes
                          resolved-scalars
                          gt-lit-lit
                          gt-col-col
                          gt-col-lit
                          gt-lit-col
                          ==
    %gte
      %:  apply-datum-op  l
                          r
                          map-meta
                          qualifier-lookup
                          named-ctes
                          resolved-scalars
                          gte-lit-lit
                          gte-col-col
                          gte-col-lit
                          gte-lit-col
                          ==
    %lt
      %:  apply-datum-op  l
                          r
                          map-meta
                          qualifier-lookup
                          named-ctes
                          resolved-scalars
                          lt-lit-lit
                          lt-col-col
                          lt-col-lit
                          lt-lit-col
                          ==
    %lte
      %:  apply-datum-op  l
                          r
                          map-meta
                          qualifier-lookup
                          named-ctes
                          resolved-scalars
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
  |=  [a=@ b=@ typ=@ta c=data-row]
  ^-  ?
  =/  x  .*(data.c [%0 b])
  =/  xv  ?@(x x ;;(@ +.x))
  ?:  =(typ ~.rs)  (equ:rs `@rs`a `@rs`xv)
  ?:  =(typ ~.rd)  (equ:rd `@rd`a `@rd`xv)
  =(a xv)
::
++  eq-col-lit
  |=  [a=@ b=@ typ=@ta c=data-row]
  ^-  ?
  =/  x  .*(data.c [%0 a])
  =/  xv  ?@(x x ;;(@ +.x))
  ?:  =(typ ~.rs)  (equ:rs `@rs`xv `@rs`b)
  ?:  =(typ ~.rd)  (equ:rd `@rd`xv `@rd`b)
  =(xv b)
::
++  eq-col-col
  |=  [a=@ b=@ typ=@ta c=data-row]
  ^-  ?
  =/  x  .*(data.c [%0 a])
  =/  y  .*(data.c [%0 b])
  =/  xv  ?@(x x ;;(@ +.x))
  =/  yv  ?@(y y ;;(@ +.y))
  ?:  =(typ ~.rs)  (equ:rs `@rs`xv `@rs`yv)
  ?:  =(typ ~.rd)  (equ:rd `@rd`xv `@rd`yv)
  ?@(x =(x y) =(xv yv))
::
++  eq-lit-lit
  |=  [a=@ b=@ typ=@ta]
  ^-  ?
  ?:  =(typ ~.rs)  (equ:rs `@rs`a `@rs`b)
  ?:  =(typ ~.rd)  (equ:rd `@rd`a `@rd`b)
  =(a b)
::
::  neq
::
++  neq-lit-col
  |=  [a=@ b=@ typ=@ta c=data-row]
  ^-  ?
  =/  x  .*(data.c [%0 b])
  =/  xv  ?@(x x ;;(@ +.x))
  ?:  =(typ ~.rs)  ?!((equ:rs `@rs`a `@rs`xv))
  ?:  =(typ ~.rd)  ?!((equ:rd `@rd`a `@rd`xv))
  ?!(=(a xv))
::
++  neq-col-lit
  |=  [a=@ b=@ typ=@ta c=data-row]
  ^-  ?
  =/  x  .*(data.c [%0 a])
  =/  xv  ?@(x x ;;(@ +.x))
  ?:  =(typ ~.rs)  ?!((equ:rs `@rs`xv `@rs`b))
  ?:  =(typ ~.rd)  ?!((equ:rd `@rd`xv `@rd`b))
  ?!(=(xv b))
::
++  neq-col-col
  |=  [a=@ b=@ typ=@ta c=data-row]
  ^-  ?
  =/  x  .*(data.c [%0 a])
  =/  y  .*(data.c [%0 b])
  =/  xv  ?@(x x ;;(@ +.x))
  =/  yv  ?@(y y ;;(@ +.y))
  ?:  =(typ ~.rs)  ?!((equ:rs `@rs`xv `@rs`yv))
  ?:  =(typ ~.rd)  ?!((equ:rd `@rd`xv `@rd`yv))
  ?@(x ?!(=(x y)) ?!(=(xv yv)))
::
++  neq-lit-lit
  |=  [a=@ b=@ typ=@ta]
  ^-  ?
  ?:  =(typ ~.rs)  ?!((equ:rs `@rs`a `@rs`b))
  ?:  =(typ ~.rd)  ?!((equ:rd `@rd`a `@rd`b))
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
  ?:  =(typ ~.rd)  (gth:rd a ?@(x x ;;(@ +.x)))
  ?:  =(typ ~.sd)  =((cmp:si `@s`a `@s`?@(x x ;;(@ +.x))) --1)
  (gth a ?@(x x ;;(@ +.x)))
::
++  gt-col-lit
  |=  [a=@ b=@ typ=@ta c=data-row]
  ^-  ?
  =/  x  .*(data.c [%0 a])
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    ?:  =(?@(x x ;;(@ +.x)) b)  %.n
    (alpha `@t`b ?@(x `@t`x `@t`;;(@ +.x)))
  ?:  =(typ ~.rd)  (gth:rd ?@(x x ;;(@ +.x)) b)
  ?:  =(typ ~.sd)  =((cmp:si `@s`?@(x x ;;(@ +.x)) `@s`b) --1)
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
    ?:  =(typ ~.rd)  (gth:rd x ;;(@ y))
    ?:  =(typ ~.sd)  =((cmp:si `@s`x `@s`;;(@ y)) --1)
    (gth x ;;(@ y))
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    ?:  =(;;(@ +.x) ;;(@ +.y))  %.n
    (alpha ;;(@ +.y) ;;(@ +.x))
  ?:  =(typ ~.rd)  (gth:rd ;;(@ +.x) ;;(@ +.y))
  ?:  =(typ ~.sd)  =((cmp:si `@s`;;(@ +.x) `@s`;;(@ +.y)) --1)
  (gth ;;(@ +.x) ;;(@ +.y))
::
++  gt-lit-lit
  |=  [a=@ b=@ typ=@ta]
  ^-  ?
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    ?:  =(a b)  %.n
    (alpha b a)
  ?:  =(typ ~.rd)  (gth:rd a b)
  ?:  =(typ ~.sd)  =((cmp:si `@s`a `@s`b) --1)
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
  ?:  =(typ ~.rd)  (gte:rd a ?@(x x ;;(@ +.x)))
  ?:  =(typ ~.sd)  ?!(=((cmp:si `@s`a `@s`?@(x x ;;(@ +.x))) -1))
  (gte a ?@(x x ;;(@ +.x)))
::
++  gte-col-lit
  |=  [a=@ b=@ typ=@ta c=data-row]
  ^-  ?
  =/  x  .*(data.c [%0 a])
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    (alpha b ?@(x `@t`x `@t`;;(@ +.x)))
  ?:  =(typ ~.rd)  (gte:rd ?@(x x ;;(@ +.x)) b)
  ?:  =(typ ~.sd)  ?!(=((cmp:si `@s`?@(x x ;;(@ +.x)) `@s`b) -1))
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
    ?:  =(typ ~.rd)  (gte:rd x ;;(@ y))
    ?:  =(typ ~.sd)  ?!(=((cmp:si `@s`x `@s`;;(@ y)) -1))
    (gte x ;;(@ y))
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    (alpha `@t`;;(@ +.y) `@t`;;(@ +.x))
  ?:  =(typ ~.rd)  (gte:rd ;;(@ +.x) ;;(@ +.y))
  ?:  =(typ ~.sd)  ?!(=((cmp:si `@s`;;(@ +.x) `@s`;;(@ +.y)) -1))
  (gte ;;(@ +.x) ;;(@ +.y))
::
++  gte-lit-lit
  |=  [a=@ b=@ typ=@ta]
  ^-  ?
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    (alpha `@t`b `@t`a)
  ?:  =(typ ~.rd)  (gte:rd a b)
  ?:  =(typ ~.sd)  ?!(=((cmp:si `@s`a `@s`b) -1))
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
  ?:  =(typ ~.rd)  (lth:rd a ?@(x x ;;(@ +.x)))
  ?:  =(typ ~.sd)  =((cmp:si `@s`a `@s`?@(x x ;;(@ +.x))) -1)
  (lth a ?@(x x ;;(@ +.x)))
::
++  lt-col-lit
  |=  [a=@ b=@ typ=@ta c=data-row]
  ^-  ?
  =/  x  .*(data.c [%0 a])
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    ?:  =(?@(x x ;;(@ +.x)) b)  %.n
    (alpha ?@(x `@t`x `@t`;;(@ +.x)) `@t`b)
  ?:  =(typ ~.rd)  (lth:rd ?@(x x ;;(@ +.x)) b)
  ?:  =(typ ~.sd)  =((cmp:si `@s`?@(x x ;;(@ +.x)) `@s`b) -1)
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
    ?:  =(typ ~.rd)  (lth:rd x ;;(@ y))
    ?:  =(typ ~.sd)  =((cmp:si `@s`x `@s`;;(@ y)) -1)
    (lth x ;;(@ y))
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    ?:  =(;;(@ +.x) ;;(@ +.y))  %.n
    (alpha `@t`;;(@ +.x) `@t`;;(@ +.y))
  ?:  =(typ ~.rd)  (lth:rd ;;(@ +.x) ;;(@ +.y))
  ?:  =(typ ~.sd)  =((cmp:si `@s`;;(@ +.x) `@s`;;(@ +.y)) -1)
  (lth ;;(@ +.x) ;;(@ +.y))
::
++  lt-lit-lit
  |=  [a=@ b=@ typ=@ta]
  ^-  ?
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    ?:  =(a b)  %.n
    (alpha `@t`a `@t`b)
  ?:  =(typ ~.rd)  (lth:rd a b)
  ?:  =(typ ~.sd)  =((cmp:si `@s`a `@s`b) -1)
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
  ?:  =(typ ~.rd)  (lte:rd a ?@(x x ;;(@ +.x)))
  ?:  =(typ ~.sd)  ?!(=((cmp:si `@s`a `@s`?@(x x ;;(@ +.x))) --1))
  (lte a ?@(x x ;;(@ +.x)))
::
++  lte-col-lit
  |=  [a=@ b=@ typ=@ta c=data-row]
  ^-  ?
  =/  x  .*(data.c [%0 a])
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    (alpha ?@(x `@t`x `@t`;;(@ +.x)) b)
  ?:  =(typ ~.rd)  (lte:rd ?@(x x ;;(@ +.x)) b)
  ?:  =(typ ~.sd)  ?!(=((cmp:si `@s`?@(x x ;;(@ +.x)) `@s`b) --1))
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
    ?:  =(typ ~.rd)  (lte:rd x ;;(@ y))
    ?:  =(typ ~.sd)  ?!(=((cmp:si `@s`x `@s`;;(@ y)) --1))
    (lte x ;;(@ y))
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    (alpha `@t`;;(@ +.x) `@t`;;(@ +.y))
  ?:  =(typ ~.rd)  (lte:rd ;;(@ +.x) ;;(@ +.y))
  ?:  =(typ ~.sd)  ?!(=((cmp:si `@s`;;(@ +.x) `@s`;;(@ +.y)) --1))
  (lte ;;(@ +.x) ;;(@ +.y))
::
++  lte-lit-lit
  |=  [a=@ b=@ typ=@ta]
  ^-  ?
  ?:  |(=(typ ~.t) =(typ ~.ta) =(typ ~.tas))
    (alpha `@t`a `@t`b)
  ?:  =(typ ~.rd)  (lte:rd a b)
  ?:  =(typ ~.sd)  ?!(=((cmp:si `@s`a `@s`b) --1))
  (lte a b)
::
::  in
::
++  in-lit-list
  |=  [a=@ typ=@ta b=(list @) c=data-row]
  ^-  ?
  |-
  ?~  b  %.n
  =/  match
    ?:  =(typ ~.rs)  (equ:rs `@rs`a `@rs`-.b)
    ?:  =(typ ~.rd)  (equ:rd `@rd`a `@rd`-.b)
    =(a -.b)
  ?:  match  %.y
  $(b +.b)
::
++  in-col-list
  |=  [a=@ typ=@ta b=(list @) c=data-row]
  ^-  ?
  =/  x  .*(data.c [%0 a])
  =/  val  ?@(x x ;;(@ +.x))
  |-
  ?~  b  %.n
  =/  match
    ?:  =(typ ~.rs)  (equ:rs `@rs`val `@rs`-.b)
    ?:  =(typ ~.rd)  (equ:rd `@rd`val `@rd`-.b)
    =(val -.b)
  ?:  match  %.y
  $(b +.b)
::
::  not in
::
++  not-in-lit-list
  |=  [a=@ typ=@ta b=(list @) c=data-row]
  ^-  ?
  |-
  ?~  b  %.y
  =/  match
    ?:  =(typ ~.rs)  (equ:rs `@rs`a `@rs`-.b)
    ?:  =(typ ~.rd)  (equ:rd `@rd`a `@rd`-.b)
    =(a -.b)
  ?:  match  %.n
  $(b +.b)
::
++  not-in-col-list
  |=  [a=@ typ=@ta b=(list @) c=data-row]
  ^-  ?
  =/  x  .*(data.c [%0 a])
  =/  val  ?@(x x ;;(@ +.x))
  |-
  ?~  b  %.y
  =/  match
    ?:  =(typ ~.rs)  (equ:rs `@rs`val `@rs`-.b)
    ?:  =(typ ~.rd)  (equ:rd `@rd`val `@rd`-.b)
    =(val -.b)
  ?:  match  %.n
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
  [%unqualified-column name.a alias.a]
--
