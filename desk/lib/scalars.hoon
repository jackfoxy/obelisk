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
      (prepare-case scalar named-ctes qualifier-lookup map-meta scalars)
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
      (prepare-arithmetic scalar named-ctes qualifier-lookup map-meta scalars)
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
      :+  %fn
        ~.sd  ::typ
        |=  =data-row
        ^-  dime
        =/  expr=resolved-scalar  %:  evaluate-datum-or-scalar
                      numeric-expression:;;(abs:ast scalar)
                      named-ctes
                      qualifier-lookup
                      map-meta
                      scalars
                      ==
        :-  %sd
            ?:  ?=(literal-value:ast expr)
              (abs:si +>.expr)
            (abs:si +:(f.expr data-row))
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
  ::  dispatch to searched or simple form based on target presence
  |=  $:  scalar=case:ast
          =named-ctes
          =qualifier-lookup
          =map-meta
          scalars=(map @tas resolved-scalar)
          ==
  ^-  resolved-scalar
  ?~  target.scalar
    %:  prepare-case-searched  scalar
                               named-ctes
                               qualifier-lookup
                               map-meta
                               scalars
                               ==
  %:  prepare-case-simple  scalar
                           named-ctes
                           qualifier-lookup
                           map-meta
                           scalars
                           ==
::
++  prepare-case-searched
  ::  searched form: CASE WHEN <predicate> THEN ... END
  |=  $:  scalar=case:ast
          =named-ctes
          =qualifier-lookup
          =map-meta
          scalars=(map @tas resolved-scalar)
          ==
  ^-  resolved-scalar
  =/  cases  cases.scalar
  ?~  cases  ~|("cases can't be empty" !!)
  ::  check all then-values and else share a common type; capture return type
  =/  then-dos=(list datum-or-scalar:ast)
    %+  turn  cases
    |=  cwt=case-when-then:ast
    then.cwt
  =/  [typ=@ta validated=(list datum-or-scalar:ast)]
    %:  check-consistent-types
      ?~(else.scalar then-dos [(need else.scalar) then-dos])
      ~
      map-meta
      scalars
      named-ctes
      ==
  =/  fns-to-apply  %:  case-searched-fns  scalar
                                           named-ctes
                                           qualifier-lookup
                                           map-meta
                                           scalars
                                           ==
  :+  %fn
      typ
      |=  =data-row
      ^-  dime
      |-
      ?~  fns-to-apply  ~|("no case matched" !!)
      =/  fn-datum  -.fns-to-apply
      ?:  (-.fn-datum data-row)
        (apply-scalar data-row +.fn-datum)
      $(fns-to-apply +.fns-to-apply)
::
++  prepare-case-simple
  ::  simple form: CASE <expression> WHEN <expression> THEN ... END
  |=  $:  scalar=case:ast
          =named-ctes
          =qualifier-lookup
          =map-meta
          scalars=(map @tas resolved-scalar)
          ==
  ^-  resolved-scalar
  =/  cases  cases.scalar
  ?~  cases  ~|("cases can't be empty" !!)
  ::  check that target and all when-values share a common type
  =/  when-dos=(list datum-or-scalar:ast)
    %+  turn  cases
    |=  cwt=case-when-then:ast
    ?:  ?=(predicate-component:ast -.when.cwt)  ~|("unreachable" !!)
    when.cwt
  =/  [cmp-typ=@ta cmp-valid=(list datum-or-scalar:ast)]
    %:  check-consistent-types
      [(need target.scalar) when-dos]
      ~
      map-meta
      scalars
      named-ctes
      ==
  ::  check all then-values and else share a common type; capture return type
  =/  then-dos=(list datum-or-scalar:ast)
    %+  turn  cases
    |=  cwt=case-when-then:ast
    then.cwt
  =/  [typ=@ta validated=(list datum-or-scalar:ast)]
    %:  check-consistent-types
      ?~(else.scalar then-dos [(need else.scalar) then-dos])
      ~
      map-meta
      scalars
      named-ctes
      ==
  =/  fns-to-apply  %:  case-simple-fns  scalar
                                         named-ctes
                                         qualifier-lookup
                                         map-meta
                                         scalars
                                         ==
  :+  %fn
      typ
      |=  =data-row
      ^-  dime
      |-
      ?~  fns-to-apply  ~|("no case matched" !!)
      =/  fn-datum  -.fns-to-apply
      ?:  (-.fn-datum data-row)
        (apply-scalar data-row +.fn-datum)
      $(fns-to-apply +.fns-to-apply)
::
++  case-searched-fns
  ::  build (predicate resolved-scalar) pairs for the simple CASE form;
  ::  each predicate compares target against a when-value at runtime.
  ::  if else.scalar is present, appends a catch-all entry whose predicate
  ::  always returns %.y.
  |=  $:  scalar=case:ast
          =named-ctes
          =qualifier-lookup
          =map-meta
          scalars=(map @tas resolved-scalar)
          ==
  ^-  (list [$-(data-row ?) resolved-scalar])
  =/  fns=(list [$-(data-row ?) resolved-scalar])
        %+  turn  cases.scalar
                  |=  cwt=case-when-then:ast
                  =/  qualified-pred
                        %+  normalize-predicate  ;;(predicate:ast when.cwt)
                                                 qualifier-lookup
                  :-  %:  pred-ops-and-conjs  qualified-pred
                                              map-meta
                                              qualifier-lookup
                                              ==
                      %:  evaluate-datum-or-scalar  then.cwt
                                                    named-ctes
                                                    qualifier-lookup
                                                    map-meta
                                                    scalars
                                                    ==
  ?~  else.scalar  fns
  =/  else-rs  %:  evaluate-datum-or-scalar  (need else.scalar)
                                             named-ctes
                                             qualifier-lookup
                                             map-meta
                                             scalars
                                             ==
  %+  weld  fns
  ^-  (list [$-(data-row ?) resolved-scalar])
      ~[[|=(=data-row %.y) else-rs]]
::
++  case-simple-fns
  ::  build (predicate resolved-scalar) pairs for the simple CASE form;
  ::  each predicate takes [data-row target when] and tests target == when.
  ::  if else.scalar is present, appends a catch-all that always succeeds.
  |=  $:  scalar=case:ast
          =named-ctes
          =qualifier-lookup
          =map-meta
          scalars=(map @tas resolved-scalar)
          ==
  ^-  (list [$-(data-row ?) resolved-scalar])
  =/  eq-pred
    |=  [target=datum-or-scalar:ast when=datum-or-scalar:ast =data-row]
    ^-  ?
    =/  target-val
          %+  apply-scalar  data-row
                            %:  evaluate-datum-or-scalar  target
                                                          named-ctes
                                                          qualifier-lookup
                                                          map-meta
                                                          scalars
                                                          ==
    =/  when-val
          %+  apply-scalar  data-row
                            %:  evaluate-datum-or-scalar  when
                                                          named-ctes
                                                          qualifier-lookup
                                                          map-meta
                                                          scalars
                                                          ==
    =(target-val when-val)
  =/  fns  %+  turn  cases.scalar
                     |=  cwt=case-when-then:ast
                     :-  ?:  ?=(datum-or-scalar:ast when.cwt)
                         |=  =data-row
                         %^  eq-pred  (need target.scalar)
                                     ;;(datum-or-scalar:ast when.cwt)
                                     data-row
                         |=  =data-row
                         =/  qualified-pred
                           %+  normalize-predicate  ;;(predicate:ast when.cwt)
                                                   qualifier-lookup
                         %-  %^  pred-ops-and-conjs  qualified-pred
                                                     map-meta
                                                     qualifier-lookup
                             data-row
                         %:  evaluate-datum-or-scalar  then.cwt
                                                       named-ctes
                                                       qualifier-lookup
                                                       map-meta
                                                       scalars
                                                       ==
  ?~  else.scalar  fns
  =/  else-rs  %:  evaluate-datum-or-scalar  (need else.scalar)
                                             named-ctes
                                             qualifier-lookup
                                             map-meta
                                             scalars
                                             ==
  %+  weld  fns
  ^-  (list [$-(data-row ?) resolved-scalar])
      ~[[|=(=data-row %.y) else-rs]]
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
++  prepare-arithmetic
    |=  $:
          scalar=arithmetic:ast
          =named-ctes
          =qualifier-lookup
          =map-meta
          scalars=(map @tas resolved-scalar)
        ==
    ^-  resolved-scalar
    ?-  operator.scalar
      ::
      %lus
        %:  basic-arithmetic  scalar
                              named-ctes
                              qualifier-lookup
                              map-meta
                              scalars
                              add
                              ==
      ::
      %hep
        %:  basic-arithmetic  scalar
                              named-ctes
                              qualifier-lookup
                              map-meta
                              scalars
                              sub
                              ==
      ::
      %tar
        %:  basic-arithmetic  scalar
                              named-ctes
                              qualifier-lookup
                              map-meta
                              scalars
                              mul
                              ==
      ::
      %fas
        %:  basic-arithmetic  scalar
                              named-ctes
                              qualifier-lookup
                              map-meta
                              scalars
                              div
                              ==
      ::
      %ket
        %:  basic-arithmetic  scalar
                              named-ctes
                              qualifier-lookup
                              map-meta
                              scalars
                              pow
                              ==
      ::
      %cen
        %:  basic-arithmetic  scalar
                              named-ctes
                              qualifier-lookup
                              map-meta
                              scalars
                              mod
                              ==
    ==
::
++  basic-arithmetic
    |=  $:
          scalar=arithmetic:ast
          =named-ctes
          =qualifier-lookup
          =map-meta
          scalars=(map @tas resolved-scalar)
          operator=$-([@ud @ud] @ud)
        ==
    ^-  resolved-scalar
    :+  %fn
        ~.ud  ::typ
        |=  =data-row
        ^-  dime
        =/  evald-left  %:  evaluate-datum-or-scalar  left.scalar
                                                      named-ctes
                                                      qualifier-lookup
                                                      map-meta
                                                      scalars
                                                      ==
        =/  evald-right  %:  evaluate-datum-or-scalar  right.scalar
                                                        named-ctes
                                                        qualifier-lookup
                                                        map-meta
                                                        scalars
                                                        ==
        :-  ~.ud  ::typ
            %+  operator  ?:  ?=(literal-value:ast evald-left)
                              +>.evald-left
                            +:(f.evald-left data-row)
                            ?:  ?=(literal-value:ast evald-right)
                              +>.evald-right
                            +:(f.evald-right data-row)
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
++  got-qualified-col-type
  |=  [=qualified-map-meta col=qualified-column:ast]
  ^-  @ta
  -:(~(got bi:mip +.qualified-map-meta) qualifier.col name.col)
::
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
  |=  $:  datum=?(datum-or-scalar:ast scalar-function:ast)
          =named-ctes
          =qualifier-lookup
          =map-meta
          scalars=(map @tas resolved-scalar)
          ==
  ^-  resolved-scalar
  ~|  "evaluate-datum-or-scalar: failed {<datum>}"
  ?+  datum  %:  prepare-scalar  ;;(scalar-function:ast datum)
                                 named-ctes
                                 qualifier-lookup
                                 map-meta
                                 scalars
                                 ==
    ::
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
