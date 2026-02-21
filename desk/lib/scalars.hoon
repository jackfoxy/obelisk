:: this file  will contain code that handles scalars in the engine
/-  ast, *obelisk
/+  *predicate, utils, mip
|%
:: inventory:
:: - we know the qualified table (or tables in case of a join) we're acting on;
::   they are the keys in type.lookups
:: - we know the columns we're acting on, they come from data-row
:: - we know what column names map to qualified columns (in case of unqualified)
::   these are in qualifier.lookups
+$  lookups  $:
              :: map from column name to list of qualified tables that have it
              :: needs to have only one in list, otherwise crash
              :: use only with unqualified tables, assume qualified columns
              :: that get here exist
              qualifier=(map @tas (list qualified-table:ast))
              :: either %qualified-map-meta or %unqualified-map-meta
              :: assume it's correct
              :: +$  qualified-map-meta
              ::   $:  %qualified-map-meta
              ::     (map qualified-table (map @tas @ta))
              ::     ==
              :: +$  unqualified-map-meta
              ::   $:  %unqualified-map-meta
              ::     (map @tas @ta)
              ::     ==
              :: +$  map-meta  $%(qualified-map-meta unqualified-map-meta)
              type=map-meta
             ==
++  apply-scalar
    |=  [row=data-row scalar=$-(data-row dime)]
    ^-  dime
    (scalar row)
++  prepare-scalar
    |=  $:
          scalar=scalar-function:ast
          =named-ctes
          =lookups
          scalars=(map @t scalar-function:ast)
        ==
    ^-  $-(data-row dime)
    ?-    -.scalar
        %if-then-else
      (prepare-if-then-else scalar named-ctes lookups scalars)
    ::
        %case
      (prepare-case scalar named-ctes lookups scalars)
    ::
        %coalesce
      (prepare-coalesce scalar named-ctes lookups scalars)
    ::
        %arithmetic
      (prepare-arithmetic scalar named-ctes lookups scalars)
    ::
        %scalar-name
      =/  resolved  (~(get by scalars) name.scalar)
      ?~  resolved
        |=  *
        ~|("no scalar with name: {<name.scalar>}" !!)
      (prepare-scalar (need resolved) named-ctes lookups scalars)
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
        !!
      ::|=  =data-row
      ::=/  expr
      ::  %-  %:  evaluate-datum-or-scalar
      ::        numeric-expression.scalar
      ::        named-ctes
      ::        lookups
      ::        scalars
      ::      ==
      ::  data-row
      ::[~.u (abs:si +.expr)]
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
::++  datum-or-scalar  
::  $%
::    qualified-column
::    unqualified-column
::    literal-value
::    cte-name
::    scalar-function
::    ==
++  get-qualified-col-type
  |=  [map-meta=qualified-map-meta col=qualified-column:ast]
  ^-  @ta
  -:(~(got bi:mip +.map-meta) qualifier.col name.col)

++  get-column-data
   |=  [=data-row map-meta=qualified-map-meta col=qualified-column:ast]
   ^-  dime
   ?-    -.data-row
       %joined-row
     =/  maybe-table  (~(get by data.data-row) qualifier.col)
     ?~  maybe-table
       ~|("no table" !!)
     =/  value  (~(get by (need maybe-table)) name.col)
     ?~  value
       ~|("no col" !!)
     =/  type  (get-qualified-col-type map-meta col)
     [type (need value)]
     ::
       %indexed-row
     =/  value  (~(get by data.data-row) name.col)
     ?~  value
       ~|("no col" !!)
     =/  type  (get-qualified-col-type map-meta col)
     [type (need value)]
   ==

::++  evaluate-datum-or-scalar
::   |=  $:
::         datum=datum-or-scalar:ast
::         =named-ctes
::         =lookups
::         scalars=(map @tas scalar-function:ast)
::       ==
::   ^-  $-(data-row dime)
::   ?:  ?=(qualified-column:ast datum)
::     :: todo: check that data-row contains column 
::     :: todo: verify type of column ==
::     ?>  ?=(%qualified-map-meta -.type.lookups)
::     |=(=data-row (get-column-data data-row type.lookups datum))
::   ?:  ?=(unqualified-column:ast datum)
::     =/  maybe-table-list  (~(get by qualifier.lookups) name.datum)
::     ?~  maybe-table-list
::       ~|("no table!" !!)
::     =/  table-list  (need maybe-table-list)
::     ?:  (gth (lent table-list) 1)
::       ~|("too many tables!" !!)
::     =/  column=qualified-column:ast
::       [%qualified-column -.table-list name.datum ~]
::     :: not sure if this is good, like at some point i might also get an
::     :: unqualified lookup type
::     ?>  ?=(%qualified-map-meta -.type.lookups)
::     |=(=data-row (get-column-data data-row type.lookups column))
::   ?:  ?=(literal-value:ast datum)
::     |=(r=data-row +.datum)
::   ?:  ?=(%cte-name -.datum)
::     ~|("unimplemented" !!)
::   :: we can't ?=(scalar-function:ast datum), it crashes with a %fish-loop
::   :: because it's a recursive type. However since we're switching on
::   :: datum-or-scalar if we exhaust the other types in the union here at
::   :: end of the switch it can only be a scalar function. we bind it to
::   :: the 'scalar' face to add a type guard
::   =/  scalar=scalar-function:ast  datum
::   ?:  ?=(scalar-name:ast scalar)
::     =/  maybe-resolved-scalar  (~(get by scalars) name.scalar)
::     ?~  maybe-resolved-scalar
::       ~|("no scalar found!" !!)
::     %:  evaluate-datum-or-scalar
::       (need maybe-resolved-scalar)
::       named-ctes
::       lookups
::       scalars
::     ==
::   (prepare-scalar scalar named-ctes lookups scalars)
::
++  prepare-if-then-else
    |=  $:
          scalar=if-then-else:ast
          =named-ctes
          =lookups
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

    !!

    ::=/  qualified-if  (normalize-predicate if.scalar qualifier.lookups)
    ::=/  pred-result
    ::  (pred-ops-and-conjs qualified-if type.lookups qualifier.lookups)
    ::|=  d=data-row
    ::?:  =((pred-result d) %.y)
    ::  ((evaluate-datum-or-scalar then.scalar named-ctes lookups scalars) d)
    ::((evaluate-datum-or-scalar else.scalar named-ctes lookups scalars) d)
::
++  prepare-case
    |=  $:
          scalar=case:ast
          =named-ctes
          =lookups
          scalars=(map @t scalar-function:ast)
        ==
    ^-  $-(data-row dime)

    !!

    ::=/  cases  cases.scalar
    ::=/  is-searched-case
    ::  ?~  cases  ~|("cases can't be empty" !!)
    ::  ?=(predicate-component:ast -.when.i.cases)
    ::=/  is-searched-case-list
    ::  %:  fold:utils
    ::    cases
    ::    is-searched-case
    ::    |=  [case=case-when-then:ast state=?]
    ::    ?&(state ?=(predicate-component:ast when.case))
    ::  ==
    ::=/  fns-to-apply=(list [$-(data-row ?) datum-or-scalar:ast])
    ::  ?:  is-searched-case
    ::      :: predicates
    ::      |-
    ::      ?~  cases
    ::        ~
    ::      =/  case  i.cases
    ::      :: need this so the proper type is inferred
    ::      ?.  ?=(predicate-component:ast -.when.case)  ~|("unreachable" !!)
    ::      =/  qualified-pred
    ::           (normalize-predicate when.case qualifier.lookups)
    ::      =/  result
    ::        :-  %:  pred-ops-and-conjs
    ::              qualified-pred
    ::              type.lookups
    ::              qualifier.lookups
    ::            ==
    ::        then.case
    ::      [result $(cases +.cases)]
    ::      ::
    ::  ::  datums
    ::  =/  target-fn  
    ::    %:  evaluate-datum-or-scalar
    ::      (need target.scalar)
    ::      named-ctes
    ::      lookups
    ::      scalars
    ::    ==
    ::  |-
    ::  ?~  cases
    ::    ~
    ::  =/  case  i.cases
    ::  :: need this so the proper type is inferred
    ::  ?:  ?=(predicate-component:ast -.when.case)  ~|("unreachable" !!)
    ::  =/  when-fn
    ::    (evaluate-datum-or-scalar when.case named-ctes lookups scalars)
    ::  =/  result
    ::    :-  |=(=data-row =((target-fn data-row) (when-fn data-row)))
    ::    then.case
    ::  [result $(cases +.cases)]
    ::  ::
    ::|=  =data-row
    ::^-  dime
    ::|-
    ::?~  fns-to-apply
    ::  ?:  !=(else.scalar ~)
    ::    %-  %:  evaluate-datum-or-scalar
    ::          (need else.scalar)
    ::          named-ctes
    ::          lookups
    ::          scalars
    ::        ==
    ::    data-row
    ::  ~|("no case matched" !!)
    ::=/  fn-datum  -.fns-to-apply
    ::?:  (-.fn-datum data-row)
    ::    %-  %:  evaluate-datum-or-scalar
    ::          +.fn-datum
    ::          named-ctes
    ::          lookups
    ::          scalars
    ::        ==
    ::    data-row
    ::$(fns-to-apply +.fns-to-apply)
::
++  get-column-data-coalesce
   |=  [=data-row map-meta=qualified-map-meta col=qualified-column:ast]
   ^-  (unit dime)
   ?-    -.data-row
       %joined-row
     =/  maybe-table  (~(get by data.data-row) qualifier.col)
     ?~  maybe-table
       ~
     =/  value  (~(get by (need maybe-table)) name.col)
     ?~  value
       ~
     =/  type  (get-qualified-col-type map-meta col)
     (some [type (need value)])
     ::
       %indexed-row
     =/  value  (~(get by data.data-row) name.col)
     ?~  value
       ~
     =/  type  (get-qualified-col-type map-meta col)
     (some [type (need value)])
   ==
::
++  prepare-coalesce
    |=  $:
          scalar=coalesce:ast
          =named-ctes
          =lookups
          scalars=(map @t scalar-function:ast)
        ==
    ^-  $-(data-row dime)

    !!
    ::=/  datums  data.scalar
    ::|-
    ::^-  $-(=data-row dime)
    ::?~  datums
    ::  ::|=  *
    ::  ~|("coalesce: couldn't resolve any column" !!)
    ::=/  datum  -.datums
    ::?:  ?=(qualified-column:ast datum)
    ::  ::
    ::  ?>  ?=(%qualified-map-meta -.type.lookups)
    ::  |=  =data-row
    ::  =/  res  (get-column-data-coalesce data-row type.lookups datum)
    ::  ?~  res
    ::    (^$(datums +.datums) data-row)
    ::  (need res)
    ::?:  ?=(unqualified-column:ast datum)
    ::  :: for some reason name.datum doesn't work
    ::  =/  maybe-table-list  (~(get by qualifier.lookups) +<.datum)
    ::  ?~  maybe-table-list
    ::    $(datums +.datums)
    ::  =/  table-list  (need maybe-table-list)
    ::  ?:  (gth (lent table-list) 1)
    ::    $(datums +.datums) 
    ::  =/  column=qualified-column:ast
    ::    [%qualified-column -.table-list +<.datum ~]
    ::  ?>  ?=(%qualified-map-meta -.type.lookups)
    ::  |=  =data-row
    ::  =/  res  (get-column-data-coalesce data-row type.lookups column)
    ::  ?~  res
    ::    (^$(datums +.datums) data-row)
    ::  (need res)
    ::|=  *
    ::~|("coalesce: can only use columns" !!)
::
++  prepare-arithmetic
    |=  $:
          scalar=arithmetic:ast
          =named-ctes
          =lookups
          scalars=(map @t scalar-function:ast)
        ==
    ^-  $-(data-row dime)

    !!
    ::
    ::?-    operator.scalar
    ::    %lus
    ::  |=  =data-row
    ::  =/  evald-left  
    ::    %-  (evaluate-datum-or-scalar left.scalar named-ctes lookups scalars)
    ::    data-row
    ::  =/  evald-right  
    ::    %-  (evaluate-datum-or-scalar right.scalar named-ctes lookups scalars)
    ::    data-row
    ::  ?:  =(-.evald-left -.evald-right)
    ::    [-.evald-left (add +.evald-left +.evald-right)]
    ::  ~|  "operands not of the sime type: {<-.evald-left>}, {<-.evald-right>}"
    ::  !!
    ::::
    ::    %hep
    ::  |=  =data-row
    ::  =/  evald-left  
    ::    %-  (evaluate-datum-or-scalar left.scalar named-ctes lookups scalars)
    ::    data-row
    ::  =/  evald-right  
    ::    %-  (evaluate-datum-or-scalar right.scalar named-ctes lookups scalars)
    ::    data-row
    ::  ?:  =(-.evald-left -.evald-right)
    ::    [-.evald-left (sub +.evald-left +.evald-right)]
    ::  ~|  "operands not of the sime type: {<-.evald-left>}, {<-.evald-right>}"
    ::  !!
    ::::
    ::    %tar
    ::  |=  =data-row
    ::  =/  evald-left  
    ::    %-  (evaluate-datum-or-scalar left.scalar named-ctes lookups scalars)
    ::    data-row
    ::  =/  evald-right  
    ::    %-  (evaluate-datum-or-scalar right.scalar named-ctes lookups scalars)
    ::    data-row
    ::  ?:  =(-.evald-left -.evald-right)
    ::    [-.evald-left (mul +.evald-left +.evald-right)]
    ::  ~|  "operands not of the sime type: {<-.evald-left>}, {<-.evald-right>}"
    ::  !!
    ::::
    ::    %fas
    ::  |=  =data-row
    ::  =/  evald-left  
    ::    %-  (evaluate-datum-or-scalar left.scalar named-ctes lookups scalars)
    ::    data-row
    ::  =/  evald-right  
    ::    %-  (evaluate-datum-or-scalar right.scalar named-ctes lookups scalars)
    ::    data-row
    ::  ?:  =(-.evald-left -.evald-right)
    ::    [-.evald-left (div +.evald-left +.evald-right)]
    ::  ~|  "operands not of the sime type: {<-.evald-left>}, {<-.evald-right>}"
    ::  !!
    ::::
    ::    %ket
    ::  |=  =data-row
    ::  =/  evald-left  
    ::    %-  (evaluate-datum-or-scalar left.scalar named-ctes lookups scalars)
    ::    data-row
    ::  =/  evald-right  
    ::    %-  (evaluate-datum-or-scalar right.scalar named-ctes lookups scalars)
    ::    data-row
    ::  ?:  =(-.evald-left -.evald-right)
    ::    [-.evald-left (pow +.evald-left +.evald-right)]
    ::  ~|  "operands not of the sime type: {<-.evald-left>}, {<-.evald-right>}"
    ::  !!
    ::::
    ::==
--
