:: this file  will contain code that handles scalars in the engine
/-  ast, *obelisk
/+  *predicate, utils, mip
|%
:: inventory:
:: - we know the qualified table (or tables in case of a join) we're acting on;
::   they are the keys in map-meta
:: - we know the columns we're acting on, they come from data-row
:: - we know what column names map to qualified columns (in case of unqualified)
::   these are in -.lookups
++  apply-scalar
    |=  [row=data-row scalar=$-(data-row dime)]
    ^-  dime
    (scalar row)
++  prepare-scalar
  |=  $:  =scalar:ast ::scalar=scalar-function:ast
          =named-ctes
          =qualifier-lookup
          =map-meta
          scalars=(map @t scalar-function:ast)
          ==
  ^-  $-(data-row dime)
  ?-  -.scalar.scalar
    %if-then-else
      %:  prepare-if-then-else  scalar.scalar
                                named-ctes
                                qualifier-lookup
                                map-meta
                                scalars
                                ==
  ::
    %case
      ::(prepare-case scalar named-ctes qualifier-lookup map-meta scalars)
      !!
  ::
    %coalesce
      %:  prepare-coalesce  scalar.scalar
                            named-ctes
                            qualifier-lookup
                            map-meta
                            scalars
                            ==
  ::
    %arithmetic
      ::(prepare-arithmetic scalar named-ctes qualifier-lookup map-meta scalars)
      !!
  ::
    %scalar-name
      ::=/  resolved  (~(get by scalars) name.scalar)
      ::?~  resolved
      ::  |=  *
      ::  ~|("no scalar with name: {<name.scalar>}" !!)
      ::(prepare-scalar (need resolved) named-ctes qualifier-lookup map-meta scalars)
      !!
  ::
    %getutcdate
      !!
  ::
    %day
      !!
  ::
     %month
      !!
  ::
    %year
      !!
  ::
    %abs
      ::|=  =data-row
      ::=/  expr  %-  %:  evaluate-datum-or-scalar
      ::                  numeric-expression.scalar
      ::                  named-ctes
      ::                  qualifier-lookup
      ::                  map-meta
      ::                  scalars
      ::                  ==
      ::              data-row
      ::[~.u (abs:si +.expr)]
      !!
  ::
    %log
      !!
  ::
    %floor
      !!
  ::
    %power
      !!
  ::
    %ceiling
      !!
  ::
    %round
      !!
  ::
    %sign
      !!
  ::
    %sqrt
      !!
  ::
    %len
      !!
  ::
    %left
      !!
  ::
    %right
      !!
  ::
    %substring
      !!
  ::
    %trim
      !!
  ::
    %concat
      !!
  ::
  ==
++  get-qualified-col-type
  |=  [=qualified-map-meta col=qualified-column:ast]
  ^-  @ta
  -:(~(got bi:mip +.qualified-map-meta) qualifier.col name.col)

++  get-column-data
  |=  [=qualified-map-meta col=qualified-column:ast =data-row] 
  ^-  dime
  ?-  -.data-row
      %joined-row
        =/  maybe-table  (~(get by data.data-row) qualifier.col)
        ?~  maybe-table
          ~|("no table" !!)
        =/  value  (~(get by (need maybe-table)) name.col)
        ?~  value
          ~|("no col" !!)
        =/  type  (get-qualified-col-type qualified-map-meta col)
        [type (need value)]
      %indexed-row
        =/  value  (~(get by data.data-row) name.col)
        ?~  value
          ~|("no col" !!)
        =/  type  (get-qualified-col-type qualified-map-meta col)
        [type (need value)]
      ==
::
++  evaluate-datum-or-scalar
  |=  $:  datum=datum-or-scalar:ast
          =named-ctes
          =qualifier-lookup
          =map-meta
          scalars=(map @tas scalar-function:ast)
          ==
  ^-  $-(data-row dime)
  ?:  =(%qualified-column:ast -.datum)
    :: to do: check that data-row contains column 
    :: to do: verify type of column ==
    ?>  =(%qualified-map-meta -.map-meta)
    |=  =data-row  %^  get-column-data  ;;(qualified-map-meta map-meta)
                                        ;;(qualified-column:ast datum)
                                        data-row
  ?:  ?=(unqualified-column:ast datum)
    =/  maybe-table-list  (~(get by qualifier-lookup) name.datum)
    ?~  maybe-table-list
      ~|("no table!" !!)
    =/  table-list  (need maybe-table-list)
    ?:  (gth (lent table-list) 1)
      ~|("too many tables!" !!)
    =/  column=qualified-column:ast
      [%qualified-column -.table-list name.datum ~]
    :: not sure if this is good, like at some point i might also get an
    :: unqualified lookup type
    ?>  =(%qualified-map-meta -.map-meta)
    |=(=data-row (get-column-data ;;(qualified-map-meta map-meta) column data-row))
  ?:  =(%literal-value -.datum)
    |=(r=data-row ;;(dime +.datum))
  ?:  =(%cte-name -.datum)
    ~|("to do: lookup cte-name not implemented" !!)
  ?.  =(%scalar-name -.datum)  ~|("evaluate-datum-or-scalar: can't get here" !!)
  =/  maybe-resolved-scalar  (~(get by scalars) name:;;(scalar-name datum))
  ?~  maybe-resolved-scalar
    ~|("no scalar found!" !!)
  %:  evaluate-datum-or-scalar
    (need maybe-resolved-scalar)
    named-ctes
    qualifier-lookup
    map-meta
    scalars
  ==
::
++  prepare-if-then-else
  |=  $:  scalar=if-then-else:ast
          =named-ctes
          =qualifier-lookup
          =map-meta
          scalars=(map @t scalar-function:ast)
          ==
  ^-  $-(data-row dime)
  :: pred-ops-and-conjs switches on map-meta to evaluate its arguments
  :: (so if it gets a qualified lookup type it will expect qualified
  :: columns, and same for unqual)  however we can have cases when we have
  :: a predicate with unqualified columns but scalar return values that
  :: are qualified, thus this function would need to have two lookup
  :: types? one for the predicate and one for the arguments. To simplify
  :: for now we always raise the predicates to qualified columns
  =/  qualified-if  (normalize-predicate if.scalar qualifier-lookup)
  =/  pred-result
    (pred-ops-and-conjs qualified-if map-meta qualifier-lookup)
  |=  =data-row
  ?:  =((pred-result data-row) %.y)
    %-  %:  evaluate-datum-or-scalar  then.scalar
                                      named-ctes
                                      qualifier-lookup
                                      map-meta
                                      scalars
                                      ==
        data-row
  %-  %:  evaluate-datum-or-scalar  else.scalar
                                    named-ctes
                                    qualifier-lookup
                                    map-meta
                                    scalars
                                    ==
      data-row
::
++  prepare-case
  |=  $:  scalar=case:ast
          =named-ctes
          =qualifier-lookup
          =map-meta
          scalars=(map @t scalar-function:ast)
          ==
  ^-  $-(data-row dime)
  =/  cases  cases.scalar
  ?~  cases  ~|("cases can't be empty" !!)
  =/  is-searched-case
    ::?=(predicate-component:ast -.when.i.cases)
    ?=(ops-and-conjs:ast -.when.i.cases)

  !!
::::  =/  is-searched-case-list
::::    %:  fold:utils
::::      cases
::::      is-searched-case
::::      |=  [case=case-when-then:ast state=?]
::::      ::?&(state ?=(predicate-component:ast when.case))
::::      ?&(state ?=(ops-and-conjs:ast when.case))
::::    ==
::::  =/  fns-to-apply=(list [$-(data-row ?) datum-or-scalar:ast])
::::    ?:  is-searched-case
::::        :: predicates
::::        |-
::::        ?~  cases
::::          ::~
::::          *(list [$-(data-row ?) datum-or-scalar:ast])
::::        =/  case  i.cases
::::        :: need this so the proper type is inferred
::::        ?.  ?=(predicate-component:ast -.when.case)  ~|("unreachable" !!)
::::        =/  qualified-pred
::::              (normalize-predicate when.case qualifier-lookup)
::::        =/  result
::::          :-  %:  pred-ops-and-conjs
::::                qualified-pred
::::                map-meta
::::                qualifier-lookup
::::              ==
::::          then.case
::::        [result $(cases +.cases)]
::::        ::
::::    ::  datums
::::    =/  target-fn  
::::      %:  evaluate-datum-or-scalar
::::        (need target.scalar)
::::        named-ctes
::::        qualifier-lookup
::::        map-meta
::::        scalars
::::      ==
::::    |-
::::    ?~  cases
::::      ~
::::    =/  case  i.cases
::::    :: need this so the proper type is inferred
::::    ?:  ?=(predicate-component:ast -.when.case)  ~|("unreachable" !!)
::::    =/  when-fn
::::      (evaluate-datum-or-scalar when.case named-ctes qualifier-lookup map-meta scalars)
::::    =/  result
::::      :-  |=(=data-row =((target-fn data-row) (when-fn data-row)))
::::      then.case
::::    [result $(cases +.cases)]
::::    ::
::::  |=  =data-row
::::  ^-  dime
::::  |-
::::  ?~  fns-to-apply
::::    ?:  !=(else.scalar ~)
::::      %-  %:  evaluate-datum-or-scalar
::::            (need else.scalar)
::::            named-ctes
::::            qualifier-lookup
::::            map-meta
::::            scalars
::::          ==
::::      data-row
::::    ~|("no case matched" !!)
::::  =/  fn-datum  -.fns-to-apply
::::  ?:  (-.fn-datum data-row)
::::      %-  %:  evaluate-datum-or-scalar
::::            +.fn-datum
::::            named-ctes
::::            qualifier-lookup
::::            map-meta
::::            scalars
::::          ==
::::      data-row
::::  $(fns-to-apply +.fns-to-apply)
::
++  get-column-data-coalesce
  |=  [=data-row =qualified-map-meta col=qualified-column:ast]
  ^-  (unit dime)
  ?-    -.data-row
      %joined-row
    =/  maybe-table  (~(get by data.data-row) qualifier.col)
    ?~  maybe-table
      ~
    =/  value  (~(get by (need maybe-table)) name.col)
    ?~  value
      ~
    =/  type  (get-qualified-col-type qualified-map-meta col)
    (some [type (need value)])
    ::
      %indexed-row
    =/  value  (~(get by data.data-row) name.col)
    ?~  value
      ~
    =/  type  (get-qualified-col-type qualified-map-meta col)
    (some [type (need value)])
  ==
::
++  prepare-coalesce
  |=  $:  scalar=coalesce:ast
          =named-ctes
          =qualifier-lookup
          =map-meta
          scalars=(map @t scalar-function:ast)
          ==
  ^-  $-(data-row dime)
  =/  datums  data.scalar
  |-
  ::^-  $-(=data-row dime)
  ?~  datums
    ~|("coalesce: couldn't resolve any column" !!)
  =/  datum  -.datums
  ?:  ?&  =(%qualified-column -.datum)
          =(%qualified-map-meta -.map-meta)
          ==
    |=  =data-row
    =/  res  %^  get-column-data-coalesce  data-row
                                           ;;(qualified-map-meta map-meta)
                                           ;;(qualified-column:ast datum)
    ?~  res
      (^$(datums +.datums) data-row)
    (need res)
  ?:  =(%unqualified-column:ast -.datum)
    :: for some reason name.datum doesn't work
    =/  maybe-table-list  (~(get by qualifier-lookup) name:;;(unqualified-column datum))
    ?~  maybe-table-list
      $(datums +.datums)
    =/  table-list  (need maybe-table-list)
    ?:  (gth (lent table-list) 1)
      $(datums +.datums) 
    =/  column=qualified-column:ast
      [%qualified-column -.table-list name:;;(unqualified-column datum) ~]
    ?>  ?=(%qualified-map-meta -.map-meta)
    |=  =data-row
    =/  res  (get-column-data-coalesce data-row map-meta column)
    ?~  res
      (^$(datums +.datums) data-row)
    (need res)
  ~|("coalesce: can only use columns" !!)
::
::::++  prepare-arithmetic
::::    |=  $:
::::          scalar=arithmetic:ast
::::          =named-ctes
::::          =qualifier-lookup
::::          =map-meta
::::          scalars=(map @t scalar-function:ast)
::::        ==
::::    ^-  $-(data-row dime)
::::    ?-    operator.scalar
::::        %lus
::::      |=  =data-row
::::      =/  evald-left  
::::        %-  (evaluate-datum-or-scalar left.scalar named-ctes qualifier-lookup map-meta scalars)
::::        data-row
::::      =/  evald-right  
::::        %-  (evaluate-datum-or-scalar right.scalar named-ctes qualifier-lookup map-meta scalars)
::::        data-row
::::      ?:  =(-.evald-left -.evald-right)
::::        [-.evald-left (add +.evald-left +.evald-right)]
::::      ~|  "operands not of the sime type: {<-.evald-left>}, {<-.evald-right>}"
::::          !!
::::    ::
::::        %hep
::::      |=  =data-row
::::      =/  evald-left  
::::        %-  (evaluate-datum-or-scalar left.scalar named-ctes qualifier-lookup map-meta scalars)
::::        data-row
::::      =/  evald-right  
::::        %-  (evaluate-datum-or-scalar right.scalar named-ctes qualifier-lookup map-meta scalars)
::::        data-row
::::      ?:  =(-.evald-left -.evald-right)
::::        [-.evald-left (sub +.evald-left +.evald-right)]
::::      ~|  "operands not of the sime type: {<-.evald-left>}, {<-.evald-right>}"
::::          !!
::::    ::
::::        %tar
::::      |=  =data-row
::::      =/  evald-left  
::::        %-  (evaluate-datum-or-scalar left.scalar named-ctes qualifier-lookup map-meta scalars)
::::        data-row
::::      =/  evald-right  
::::        %-  (evaluate-datum-or-scalar right.scalar named-ctes qualifier-lookup map-meta scalars)
::::        data-row
::::      ?:  =(-.evald-left -.evald-right)
::::        [-.evald-left (mul +.evald-left +.evald-right)]
::::      ~|  "operands not of the sime type: {<-.evald-left>}, {<-.evald-right>}"
::::          !!
::::    ::
::::        %fas
::::      |=  =data-row
::::      =/  evald-left  
::::        %-  (evaluate-datum-or-scalar left.scalar named-ctes qualifier-lookup map-meta scalars)
::::        data-row
::::      =/  evald-right  
::::        %-  (evaluate-datum-or-scalar right.scalar named-ctes qualifier-lookup map-meta scalars)
::::        data-row
::::      ?:  =(-.evald-left -.evald-right)
::::        [-.evald-left (div +.evald-left +.evald-right)]
::::      ~|  "operands not of the sime type: {<-.evald-left>}, {<-.evald-right>}"
::::          !!
::::    ::
::::        %ket
::::      |=  =data-row
::::      =/  evald-left  
::::        %-  (evaluate-datum-or-scalar left.scalar named-ctes qualifier-lookup map-meta scalars)
::::        data-row
::::      =/  evald-right  
::::        %-  (evaluate-datum-or-scalar right.scalar named-ctes qualifier-lookup map-meta scalars)
::::        data-row
::::      ?:  =(-.evald-left -.evald-right)
::::        [-.evald-left (pow +.evald-left +.evald-right)]
::::      ~|  "operands not of the sime type: {<-.evald-left>}, {<-.evald-right>}"
::::          !!
::::    ::
::::    ==
--
