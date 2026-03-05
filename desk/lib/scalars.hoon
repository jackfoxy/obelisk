:: this file  will contain code that handles scalars in the engine
/-  ast, *obelisk
/+  *predicate, *utils, mip
|%
:: inventory:
:: - we know the qualified table (or tables in case of a join) we're acting on;
::   they are the keys in map-meta
:: - we know the columns we're acting on, they come from data-row
:: - we know what column names map to qualified columns (in case of unqualified)
::   these are in -.lookups
++  apply-scalar
    |=  [row=data-row =resolved-scalar]
    ^-  dime
    ?-  -.resolved-scalar
      %fn
        =/  f=$-(data-row dime)  +>.resolved-scalar
        (f row)
      ::
      %literal-value
        dime.resolved-scalar
      ==
++  prepare-scalar
  |=  $:  scalar=scalar-function:ast
          =named-ctes
          =qualifier-lookup
          =map-meta
          scalars=(map @tas resolved-scalar)
          ==
  ^-  resolved-scalar
  ?-  -.scalar
    %if-then-else
      %:  prepare-if-then-else  scalar
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
      %:  prepare-coalesce  scalar
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
::
++  prepare-if-then-else
  |=  $:  scalar=if-then-else:ast
          =named-ctes
          =qualifier-lookup
          =map-meta
          scalars=(map @tas resolved-scalar)
          ==
  ^-  resolved-scalar
  :: pred-ops-and-conjs switches on map-meta to evaluate its arguments
  :: (so if it gets a qualified lookup type it will expect qualified
  :: columns, and same for unqual)  however we can have cases when we have
  :: a predicate with unqualified columns but scalar return values that
  :: are qualified, thus this function would need to have two lookup
  :: types? one for the predicate and one for the arguments. To simplify
  :: for now we always raise the predicates to qualified columns
  =/  [typ=@ta validated=(list datum-or-scalar:ast)]
    %:  check-consistent-types
        ~[then.scalar else.scalar]
        ~
        map-meta
        scalars
        named-ctes
        ==
  =/  qualified-if  (normalize-predicate if.scalar qualifier-lookup)
  =/  pred-result
    (pred-ops-and-conjs qualified-if map-meta qualifier-lookup)
  :+  %fn
      typ
      |=  =data-row
      ^-  dime
      =/  resolved
            ?:  (pred-result data-row)
              %:  evaluate-datum-or-scalar  then.scalar
                                                named-ctes
                                                qualifier-lookup
                                                map-meta
                                                scalars
                                                ==
            %:  evaluate-datum-or-scalar  else.scalar
                                              named-ctes
                                              qualifier-lookup
                                              map-meta
                                              scalars
                                              ==
      ?:  ?=(literal-value:ast resolved)  dime.resolved
      ?:  =(%fn -.resolved)
        (f.resolved data-row)
      ~|("if-then-else: can't get here" !!)
::
++  prepare-case
  |=  $:  scalar=case:ast
          =named-ctes
          =qualifier-lookup
          =map-meta
          scalars=(map @tas resolved-scalar)
          ==
  ^-  resolved-scalar
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
++  prepare-coalesce
  |=  $:  scalar=coalesce:ast
          =named-ctes
          =qualifier-lookup
          =map-meta
          scalars=(map @tas resolved-scalar)
          ==
  ^-  resolved-scalar
  =/  [typ=@ta validated=(list datum-or-scalar:ast)]
    %:  check-consistent-types
        data.scalar
        ~
        map-meta
        scalars
        named-ctes
        ==
  ::  first item is a concrete value: return it immediately as resolved-scalar
  ?~  validated  ~|("no non-null value found in row" !!)
  ?:  =(%literal-value -.i.validated)  ;;(literal-value:ast i.validated)
  ::  otherwise build a %fn that walks validated at runtime per data-row,
  ::  returning the first non-null value; the list-walk is captured in the gate
  =/  fn
    |=  [datums=(list datum-or-scalar:ast) =data-row]
    :: to do: once outer joins implemented must test columns for existence
    ::        in data-row
    ^-  dime
    |-
    ?~  datums  ~|("coalesce: no non-null value found in row" !!)
    =/  datum  i.datums
    ::  literal-value is always exists
    ?:  =(%literal-value -.datum)  dime:;;(literal-value:ast datum)
    ?:  ?&  =(%qualified-column -.datum)
            =(%qualified-map-meta -.map-meta)
            ==
      %^  got-column-dime  ;;(qualified-map-meta map-meta)
                           ;;(qualified-column:ast datum)
                           data-row
    :: otherwise can only be unqualified-column
    =/  maybe-table-list
      (~(get by qualifier-lookup) name:;;(unqualified-column datum))
    ?~  maybe-table-list  $(datums t.datums)
    =/  table-list  (need maybe-table-list)
    ?:  (gth (lent table-list) 1)  $(datums t.datums)
    =/  column=qualified-column:ast
      [%qualified-column -.table-list name:;;(unqualified-column datum) ~]
    ?>  ?=(%qualified-map-meta -.map-meta)
    (got-column-dime map-meta column data-row)
  [%fn typ |=(=data-row (fn validated data-row))]
::
++  check-consistent-types
  ::  validate that all datum-or-scalar items share a common aura type,
  ::  and (if allowed is non-empty) that type is in the allowed list.
  ::  returns [common-type list] with any cte-name or unqualified-column
  ::  resolved via cte-to-literal replaced by their literal-value.
  ::  crashes on empty dos.
  |=  $:  dos=(list datum-or-scalar:ast)
          allowed=(list @ta)
          =map-meta
          scalars=(map @tas resolved-scalar)
          =named-ctes
          ==
  ^-  [@ta (list datum-or-scalar:ast)]
  ::  resolve type and possibly substitute item; returns [type resolved-item]
  =/  resolve-item
    |=  item=datum-or-scalar:ast
    ^-  [@ta datum-or-scalar:ast]
    ?-  item
      literal-value:ast
        [-.dime.item item]
    ::
      qualified-column:ast
        ~|  "check-consistent-types: qualified-column {<name.item>} ".
            "requires qualified map-meta"
        :-  (got-qualified-col-type ;;(qualified-map-meta map-meta) item)
            ;;(qualified-column:ast item)
    ::
      unqualified-column:ast
        =/  maybe-ta
          ?.  =(%unqualified-map-meta -.map-meta)  ~
          (~(get by +:;;(unqualified-map-meta map-meta)) name.item)
        ?~  maybe-ta
          ::  not in unqualified-map-meta: attempt CTE lookup by column name
          =/  lit=literal-value:ast
            (cte-to-literal named-ctes item)
          [p.dime.lit lit]
        [type.u.maybe-ta ;;(unqualified-column:ast item)]
    ::
      cte-name:ast
        =/  lit=literal-value:ast
          (cte-to-literal named-ctes ;;(cte-name:ast item))
        [p.dime.lit lit]
    ::
      scalar-name:ast
        ~|  "check-consistent-types: scalar {<name.item>} not found"
        =/  res  (~(got by scalars) name.item)
        ?-  -.res
            %fn           [type.res item]
            %literal-value  [p.dime.res item]
        ==
    ==
  ::  walk the list, tracking expected type, verifying consistency,
  ::  and accumulating the (possibly-substituted) output list
  =/  expected=(unit @ta)  ~
  =/  out=(list datum-or-scalar:ast)  ~
  =/  items  dos
  |-  ^-  [@ta (list datum-or-scalar:ast)]
  ?~  items
    ?~  expected
      ~|("check-consistent-types: empty argument list" !!)
    ?~  allowed
      [u.expected (flop out)]  ::  no type constraint
    ~|  %+  weld  "check-consistent-types: type {<u.expected>} "
              "not in allowed types {<allowed>}"
    ?>
      =/  ck  `(list @ta)`allowed
      |-  ^-  ?
      ?~  ck  |
      ?:  =(i.ck u.expected)  &
      $(ck t.ck)
    [u.expected (flop out)]
  =/  [t=@ta sub=datum-or-scalar:ast]  (resolve-item i.items)
  ?~  expected
    $(expected `t, out [sub out], items t.items)
  ~|  "check-consistent-types: inconsistent types, expected {<u.expected>} ".
      "but got {<t>} at {<-.i.items>}"
  ?>  =(u.expected t)
  $(out [sub out], items t.items)
::
::::++  prepare-arithmetic
::::    |=  $:
::::          scalar=arithmetic:ast
::::          =named-ctes
::::          =qualifier-lookup
::::          =map-meta
::::          scalars=(map @tas resolved-scalar)
::::        ==
::::    ^-  resolved-scalar
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
++  got-qualified-col-type
  |=  [=qualified-map-meta col=qualified-column:ast]
  ^-  @ta
  -:(~(got bi:mip +.qualified-map-meta) qualifier.col name.col)

++  got-column-dime
  |=  [=qualified-map-meta col=qualified-column:ast =data-row] 
  ^-  dime
  ~|  "got-column-dime: failed for {<col>}"
  ?-  -.data-row
      %joined-row
        :-  (got-qualified-col-type qualified-map-meta col)
            (~(got bi:mip data.data-row) qualifier.col name.col)
      ::
      %indexed-row
        :-  (got-qualified-col-type qualified-map-meta col)
            (~(got by data.data-row) name.col)
      ==
::
++  evaluate-datum-or-scalar
  |=  $:  datum=datum-or-scalar:ast
          =named-ctes
          =qualifier-lookup
          =map-meta
          scalars=(map @tas resolved-scalar)
          ==
  ^-  resolved-scalar
  ~|  "evaluate-datum-or-scalar: failed {<datum>}"
  ?-  datum
    literal-value:ast
      datum
    ::
    scalar-name:ast
      ~|  "scalar {<name.datum>} not found"
          (~(got by scalars) name.datum)
    ::
    cte-name:ast
      (cte-to-literal named-ctes datum)
    ::
    qualified-column:ast
      :+  %fn
          %+  got-qualified-col-type  ;;(qualified-map-meta map-meta)
                                      ;;(qualified-column:ast datum)
          |=  =data-row
            %^  got-column-dime  ;;(qualified-map-meta map-meta)
                                ;;(qualified-column:ast datum)
                                data-row
    ::
    unqualified-column:ast
      =/  table-list
            (~(got by qualifier-lookup) name:;;(unqualified-column:ast datum))
      ?~  table-list  ~|("no table!" !!)
      ?:  (gth (lent table-list) 1)  ~|("too many tables!" !!)
      =/  column=qualified-column:ast
        [%qualified-column -.table-list name:;;(unqualified-column:ast datum) ~]
      :+  %fn
          (got-qualified-col-type ;;(qualified-map-meta map-meta) column)
          |=  =data-row
              (got-column-dime ;;(qualified-map-meta map-meta) column data-row)
    ==
--
