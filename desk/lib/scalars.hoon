:: this file  will contain code that handles scalars in the engine
/-  ast, *obelisk
/+  *predicate, *utils, mip, math
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
    ?:  ?=(dime resolved-scalar)
      resolved-scalar
    =/  f=$-(data-row dime)  +>.resolved-scalar
    (f row)
++  prepare-scalar
  |=  $:  scalar=scalar-function:ast
          =named-ctes
          =qualifier-lookup
          =map-meta
          =resolved-scalars
          =bowl:gall
          =seed
          ==
  ^-  [@uvJ resolved-scalar]
  =/  simple-rounding-ops
    |=  $:  op-name=@tas
            expr=resolved-scalar
            rd-adjust=$-([@rd @rd] @rd)
            ==
    ^-  resolved-scalar
    =/  number-system  ?:(?=(dime expr) -.expr type.expr)
    ?.  ?=(number-systems number-system)
      ~|  "{<number-system>} not a supported number system for {<op-name>}, ".
          "need ?(~.rd ~.sd ~.ud)"
          !!
    ?:  ?=(dime expr)
      ?-  number-system
          %rd
            =/  int  (san:rd (need (toi:rd +.expr)))
            [number-system (rd-adjust int +.expr)]
          %sd  expr
          %ud  expr
          ==
    :+  %fn
      type.expr
      |=  =data-row
      ^-  dime
      =/  datum  +:(f.expr data-row)
      ?-  number-system
          %rd
            =/  int  (san:rd (need (toi:rd datum)))
            [number-system (rd-adjust int datum)]
          %sd  (f.expr data-row)
          %ud  (f.expr data-row)
          ==
  =/  prepare-time-arith-op
    |=  $:  op-name=@tas
            expr=resolved-scalar
            duration=resolved-scalar
            op-fn=$-([@ @] @)
            ==
    ^-  resolved-scalar
    =/  expr-aura  ?:(?=(dime expr) -.expr type.expr)
    =/  dur-aura   ?:(?=(dime duration) -.duration type.duration)
    ?.  ?|(=(~.da expr-aura) =(~.dr expr-aura))
      ~|  "{<expr-aura>} not a supported type for {<op-name>} time-expression,".
          " need @da or @dr"
          !!
    ?.  =(~.dr dur-aura)
      ~|  "{<dur-aura>} not a supported type for {<op-name>} duration, ".
          "need @dr"
          !!
    ?:  &(?=(dime expr) ?=(dime duration))
      [expr-aura (op-fn +.expr +.duration)]
    :+  %fn
      expr-aura
      |=  =data-row
      ^-  dime
      =/  e  ?:(?=(dime expr) +.expr +:(f.expr data-row))
      =/  d  ?:(?=(dime duration) +.duration +:(f.duration data-row))
      [expr-aura (op-fn e d)]
=/  prepare-rd-trig-op
    |=  $:  op-name=@tas
            expr=resolved-scalar
            rd-fn=$-(@rd @rd)
            ==
    ^-  resolved-scalar
    =/  number-system  ?:(?=(dime expr) -.expr type.expr)
    ?.  ?=(number-systems number-system)
      ~|  "{<number-system>} not a supported number system for {<op-name>}, ".
          "need ?(~.rd ~.sd ~.ud)"
          !!
    =/  do-op
      |=  [ns=number-systems val=@]  ^-  dime
      =/  rd-val
        ?-  ns
            %rd  `@rd`val
            %sd  (san:rd `@s`val)
            %ud  (sun:rd val)
            ==
      [~.rd (rd-fn rd-val)]
    ?:  ?=(dime expr)
      (do-op number-system +.expr)
    :+  %fn
      ~.rd
      |=  =data-row
      ^-  dime
      (do-op number-system +:(f.expr data-row))
  ?-  -.scalar
  ::
    %arithmetic
      :-  seed
      %:  prepare-arithmetic  scalar
                              named-ctes
                              qualifier-lookup
                              map-meta
                              resolved-scalars
                              bowl
                              ==

  ::
    %case
      :-  seed
      %:  prepare-case  scalar
                        named-ctes
                        qualifier-lookup
                        map-meta
                        resolved-scalars
                        bowl
                        ==
  ::
    %coalesce
      :-  seed
      %:  prepare-coalesce  scalar
                            named-ctes
                            qualifier-lookup
                            map-meta
                            resolved-scalars
                            bowl
                            ==
  ::
    %if-then-else
      :-  seed
      %:  prepare-if-then-else  scalar
                                named-ctes
                                qualifier-lookup
                                map-meta
                                resolved-scalars
                                bowl
                                ==
  ::
  ::  data functions
  ::
    %getutcdate
      [seed [~.da now.bowl]]
  ::
    %year
      =/  ps  %:  evaluate-datum  date:;;(year:ast scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      =/  expr=resolved-scalar  +.ps
      =/  aura  ?:(?=(dime expr) -.expr type.expr)
      ?.  =(~.da aura)
        ~|("{<aura>} not a supported type for %year, need @da" !!)
      ?:  ?=(dime expr)
        [seed [~.ud y:(yore `@da`+.expr)]]
      :-  seed
      :+  %fn
          ~.ud
          |=  =data-row
          ^-  dime
          [~.ud y:(yore `@da`+:(f.expr data-row))]
  ::
    %month
      =/  ps  %:  evaluate-datum  date:;;(month:ast scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      =/  expr=resolved-scalar  +.ps
      =/  aura  ?:(?=(dime expr) -.expr type.expr)
      ?.  =(~.da aura)
        ~|("{<aura>} not a supported type for %month, need @da" !!)
      ?:  ?=(dime expr)
        [seed [~.ud m:(yore `@da`+.expr)]]
      :-  seed
      :+  %fn
          ~.ud
          |=  =data-row
          ^-  dime
          [~.ud m:(yore `@da`+:(f.expr data-row))]
  ::
    %day
      =/  ps  %:  evaluate-datum  time-expression:;;(day:ast scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      =/  expr=resolved-scalar  +.ps
      =/  aura  ?:(?=(dime expr) -.expr type.expr)
      ?.  ?=(time-element:ast aura)
        ~|("{<aura>} not a supported type for %day, need @da or @dr" !!)
      =/  do-day
        ?-  aura
            %da  |=(val=@ [~.ud d.t:(yore `@da`val)])
            %dr  |=(val=@ [~.ud (div `@dr`val ~d1)])
            ==
      ?:  ?=(dime expr)
        [seed (do-day +.expr)]
      :-  seed
      :+  %fn
          ~.ud
          |=  =data-row
          ^-  dime
          (do-day +:(f.expr data-row))
  ::
    %hour
      =/  ps  %:  evaluate-datum  time-expression:;;(hour:ast scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      =/  expr=resolved-scalar  +.ps
      =/  aura  ?:(?=(dime expr) -.expr type.expr)
      ?.  ?=(time-element:ast aura)
        ~|("{<aura>} not a supported type for %hour, need @da or @dr" !!)
      =/  do-hour
        ?-  aura
            %da  |=(val=@ [~.ud h.t:(yore `@da`val)])
            %dr  |=(val=@ [~.ud (div `@dr`val ~h1)])
            ==
      ?:  ?=(dime expr)
        [seed (do-hour +.expr)]
      :-  seed
      :+  %fn
          ~.ud
          |=  =data-row
          ^-  dime
          (do-hour +:(f.expr data-row))
  ::
    %minute
      =/  ps  %:  evaluate-datum  time-expression:;;(minute:ast scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      =/  expr=resolved-scalar  +.ps
      =/  aura  ?:(?=(dime expr) -.expr type.expr)
      ?.  ?=(time-element:ast aura)
        ~|("{<aura>} not a supported type for %minute, need @da or @dr" !!)
      =/  do-minute
        ?-  aura
            %da  |=(val=@ [~.ud m.t:(yore `@da`val)])
            %dr  |=(val=@ [~.ud (div `@dr`val ~m1)])
            ==
      ?:  ?=(dime expr)
        [seed (do-minute +.expr)]
      :-  seed
      :+  %fn
          ~.ud
          |=  =data-row
          ^-  dime
          (do-minute +:(f.expr data-row))
  ::
    %second
      =/  ps  %:  evaluate-datum  time-expression:;;(second:ast scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      =/  expr=resolved-scalar  +.ps
      =/  aura  ?:(?=(dime expr) -.expr type.expr)
      ?.  ?=(time-element:ast aura)
        ~|("{<aura>} not a supported type for %second, need @da or @dr" !!)
      =/  do-second
        ?-  aura
            %da  |=(val=@ [~.ud s.t:(yore `@da`val)])
            %dr  |=(val=@ [~.ud (div `@dr`val ~s1)])
            ==
      ?:  ?=(dime expr)
        [seed (do-second +.expr)]
      :-  seed
      :+  %fn
          ~.ud
          |=  =data-row
          ^-  dime
          (do-second +:(f.expr data-row))
  ::
    %add-time
      =/  ps  %:  evaluate-datum  time-expression:;;(add-time:ast scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      =/  expr=resolved-scalar  +.ps
      =/  ps  %:  evaluate-datum  duration:;;(add-time:ast scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      =/  duration=resolved-scalar  +.ps
      :-  seed
      (prepare-time-arith-op %add-time expr duration add)
  ::
    %subtract-time
      =/  ps  %:  evaluate-datum  time-expression:;;(subtract-time:ast scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      =/  expr=resolved-scalar  +.ps
      =/  ps  %:  evaluate-datum  duration:;;(subtract-time:ast scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      =/  duration=resolved-scalar  +.ps
      :-  seed
      (prepare-time-arith-op %subtract-time expr duration sub)
  ::
  ::  numeric functions
  ::
    %abs
      =/  ps  %:  evaluate-datum  numeric-expression:;;(abs:ast scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      =/  expr=resolved-scalar  +.ps
      =/  number-system  ?:(?=(dime expr) -.expr type.expr)
      ?.  ?=(number-systems number-system)
        ~|  "{<number-system>} not a supported number system for %abs, ".
            "need ?(~.rd ~.sd ~.ud)"
            !!
      ?:  ?=(dime expr)
        :-  seed
        ?-  number-system
            ::
            %rd  :-  number-system
                     (~(abs rd:math [%z .~1e-15]) +.expr)
            ::
            %sd  [number-system (sun:si (abs:si +.expr))]
            ::
            %ud  expr
            ==
      :-  seed
      :+  %fn
        type.expr
        |=  =data-row
        ^-  dime
        ?-  number-system
            ::
            %rd  :-  number-system
                     (~(abs rd:math [%z .~1e-15]) +:(f.expr data-row))
            ::
            %sd  [number-system (sun:si (abs:si +:(f.expr data-row)))]
            ::
            %ud  (f.expr data-row)
            ==
  ::
    %log
      =/  ps  %:  evaluate-datum  float-expression:;;(log:ast scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      =/  expr=resolved-scalar  +.ps
      =/  number-system  ?:(?=(dime expr) -.expr type.expr)
      ?.  ?=(number-systems number-system)
        ~|  "{<number-system>} not a supported number system for %log, ".
            "need ?(~.rd ~.sd ~.ud)"
            !!
      =/  do-log
        |=  [ns=number-systems val=@]  ^-  dime
        ?-  ns
            %rd
              ?:  =(0 val)
                ~|  "log(0) is not a number"  !!
              ?.  (sig:rd `@rd`val)
                ~|  "log({<`@rd`val>}) is not a number"  !!
              [~.rd (~(log rd:math [%z .~1e-15]) `@rd`val)]
            %sd
              ?:  =(0 val)
                ~|  "log(0) is not a number"  !!
              ?.  (syn:si `@s`val)
                ~|  "log({<`@s`val>}) is not a number"  !!
              [~.rd (~(log rd:math [%z .~1e-15]) (san:rd `@s`val))]
            %ud
              ?:  =(0 val)
                ~|  "log(0) is not a number"  !!
              [~.rd (~(log rd:math [%z .~1e-15]) (sun:rd val))]
            ==
      ?:  ?=(dime expr)
        [seed (do-log number-system +.expr)]
      :-  seed
      :+  %fn
        ~.rd
        |=  =data-row
        ^-  dime
        (do-log number-system +:(f.expr data-row))
  ::
    %e
      [seed [~.rd .~2.718281828459045]]
  ::
    %max
      =/  ps  %:  evaluate-datum  numeric-expression-1:;;(max:ast scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      =/  expr1=resolved-scalar  +.ps
      =/  ps  %:  evaluate-datum  numeric-expression-2:;;(max:ast scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      =/  expr2=resolved-scalar  +.ps
      =/  ns1  ?:(?=(dime expr1) -.expr1 type.expr1)
      =/  ns2  ?:(?=(dime expr2) -.expr2 type.expr2)
      ?.  =(ns1 ns2)
        ~|  "max: type conflict: {<ns1>} vs {<ns2>}"  !!
      ?.  ?=(number-systems ns1)
        ~|  "{<ns1>} not a supported number system for %max, ".
            "need ?(~.rd ~.sd ~.ud)"
            !!
      =/  max-val
        |=  [a=@ b=@]  ^-  @
        ?-  ns1
            %rd  ?:  (sig:rd (sub:rd `@rd`a `@rd`b))  a  b
            %sd  ?:  (syn:si (dif:si `@s`a `@s`b))  a  b
            %ud  ?:  (gte a b)  a  b
            ==
      ?:  &(?=(dime expr1) ?=(dime expr2))
        [seed [ns1 (max-val +.expr1 +.expr2)]]
      :-  seed
      :+  %fn
        ns1
        |=  =data-row
        ^-  dime
        =/  v1  ?:(?=(dime expr1) +.expr1 +:(f.expr1 data-row))
        =/  v2  ?:(?=(dime expr2) +.expr2 +:(f.expr2 data-row))
        [ns1 (max-val v1 v2)]
  ::
    %min
      =/  ps  %:  evaluate-datum  numeric-expression-1:;;(min:ast scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      =/  expr1=resolved-scalar  +.ps
      =/  ps  %:  evaluate-datum  numeric-expression-2:;;(min:ast scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      =/  expr2=resolved-scalar  +.ps
      =/  ns1  ?:(?=(dime expr1) -.expr1 type.expr1)
      =/  ns2  ?:(?=(dime expr2) -.expr2 type.expr2)
      ?.  =(ns1 ns2)
        ~|  "min: type conflict: {<ns1>} vs {<ns2>}"  !!
      ?.  ?=(number-systems ns1)
        ~|  "{<ns1>} not a supported number system for %min, ".
            "need ?(~.rd ~.sd ~.ud)"
            !!
      =/  min-val
        |=  [a=@ b=@]  ^-  @
        ?-  ns1
            %rd  ?:  (sig:rd (sub:rd `@rd`a `@rd`b))  b  a
            %sd  ?:  (syn:si (dif:si `@s`a `@s`b))  b  a
            %ud  ?:  (gte a b)  b  a
            ==
      ?:  &(?=(dime expr1) ?=(dime expr2))
        [seed [ns1 (min-val +.expr1 +.expr2)]]
      :-  seed
      :+  %fn
        ns1
        |=  =data-row
        ^-  dime
        =/  v1  ?:(?=(dime expr1) +.expr1 +:(f.expr1 data-row))
        =/  v2  ?:(?=(dime expr2) +.expr2 +:(f.expr2 data-row))
        [ns1 (min-val v1 v2)]
  ::
    %phi
      [seed [~.rd .~1.618033988749895]]
  ::
    %pi
      [seed [~.rd .~3.141592653589793]]
  ::
    %rand
      ~|("%rand not implemented" !!)
  ::
    %tau
      [seed [~.rd .~6.283185307179586]]
  ::
    %degrees
      =/  ps  %:  evaluate-datum  numeric-expression:;;(degrees:ast scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      =/  expr=resolved-scalar  +.ps
      =/  number-system  ?:(?=(dime expr) -.expr type.expr)
      ?.  ?=(number-systems number-system)
        ~|  "{<number-system>} not a supported number system for %degrees, ".
            "need ?(~.rd ~.sd ~.ud)"
            !!
      =/  factor  (div:rd .~360 .~6.283185307179586)
      =/  do-degrees
        |=  [ns=number-systems val=@]  ^-  dime
        =/  rd-val
          ?-  ns
              %rd  `@rd`val
              %sd  (san:rd `@s`val)
              %ud  (sun:rd val)
              ==
        =/  res-rd  (mul:rd rd-val factor)
        ?-  ns
            %rd  [ns res-rd]
            %sd  :-  ns
                    %-  need  %-  toi:rd  %+  add:rd  res-rd
                                                      ?:  (sig:rd res-rd)
                                                        .~0.5
                                                      .~-0.5
            %ud  [ns (abs:si `@s`(need (toi:rd (add:rd res-rd .~0.5))))]
            ==
      ?:  ?=(dime expr)
        [seed (do-degrees number-system +.expr)]
      :-  seed
      :+  %fn
        number-system
        |=  =data-row
        ^-  dime
        (do-degrees number-system +:(f.expr data-row))
  ::
    %sin
      =/  ps  %:  evaluate-datum  numeric-expression:;;(sin:ast scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      :-  seed
      (prepare-rd-trig-op %sin +.ps ~(sin rd:math [%z .~1e-15]))
  ::
    %cos
      =/  ps  %:  evaluate-datum  numeric-expression:;;(cos:ast scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      :-  seed
      (prepare-rd-trig-op %cos +.ps ~(cos rd:math [%z .~1e-15]))
  ::
    %tan
      =/  ps  %:  evaluate-datum  numeric-expression:;;(tan:ast scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      :-  seed
      (prepare-rd-trig-op %tan +.ps ~(tan rd:math [%z .~1e-15]))
  ::
    %asin
      =/  ps  %:  evaluate-datum  numeric-expression:;;(asin:ast scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      :-  seed
      (prepare-rd-trig-op %asin +.ps ~(asin rd:math [%z .~1e-15]))
  ::
    %acos
      =/  ps  %:  evaluate-datum  numeric-expression:;;(acos:ast scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      :-  seed
      (prepare-rd-trig-op %acos +.ps ~(acos rd:math [%z .~1e-15]))
  ::
    %atan
      =/  ps  %:  evaluate-datum  numeric-expression:;;(atan:ast scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      :-  seed
      (prepare-rd-trig-op %atan +.ps ~(atan rd:math [%z .~1e-15]))
  ::
    %atan2
      =/  ps  %:  evaluate-datum  numeric-expression-1:;;(atan2:ast scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      =/  expr1=resolved-scalar  +.ps
      =/  ps  %:  evaluate-datum  numeric-expression-2:;;(atan2:ast scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      =/  expr2=resolved-scalar  +.ps
      =/  ns1  ?:(?=(dime expr1) -.expr1 type.expr1)
      =/  ns2  ?:(?=(dime expr2) -.expr2 type.expr2)
      ?.  ?=(number-systems ns1)
        ~|  "{<ns1>} not a supported number system for %atan2, ".
            "need ?(~.rd ~.sd ~.ud)"
            !!
      ?.  ?=(number-systems ns2)
        ~|  "{<ns2>} not a supported number system for %atan2, ".
            "need ?(~.rd ~.sd ~.ud)"
            !!
      =/  to-rd
        |=  [ns=number-systems val=@]  ^-  @rd
        ?-  ns
            %rd  `@rd`val
            %sd  (san:rd `@s`val)
            %ud  (sun:rd val)
            ==
      =/  do-atan2
        |=  [y=@ x=@]  ^-  dime
        [~.rd (~(atan2 rd:math [%z .~1e-15]) (to-rd ns1 y) (to-rd ns2 x))]
      ?:  &(?=(dime expr1) ?=(dime expr2))
        [seed (do-atan2 +.expr1 +.expr2)]
      :-  seed
      :+  %fn
        ~.rd
        |=  =data-row
        ^-  dime
        =/  y  ?:(?=(dime expr1) +.expr1 +:(f.expr1 data-row))
        =/  x  ?:(?=(dime expr2) +.expr2 +:(f.expr2 data-row))
        (do-atan2 y x)
  ::
    %floor
      =/  ps  %:  evaluate-datum  numeric-expression:;;(floor:ast scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      =/  expr=resolved-scalar  +.ps
      =/  floor-adjust
        |=  [int=@rd datum=@rd]
        ^-  @rd
        =/  dcm  (sub:rd datum int)
        ?:  =(0 dcm)  int
        ?:  (sig:rd datum)  int
        (sub:rd int .~1)
      :-  seed
      (simple-rounding-ops %floor expr floor-adjust)
  ::
    %ceiling
      =/  ps  %:  evaluate-datum  numeric-expression:;;(ceiling:ast scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      =/  expr=resolved-scalar  +.ps
      =/  ceiling-adjust
        |=  [int=@rd datum=@rd]
        ^-  @rd
        =/  dcm  (sub:rd datum int)
        ?:  =(0 dcm)  int
        ?:  (sig:rd datum)  (add:rd int .~1)
        int
      :-  seed
      (simple-rounding-ops %ceiling expr ceiling-adjust)
  ::
    %round
      =/  ps  %:  evaluate-datum  numeric-expression:;;(round:ast scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      =/  expr=resolved-scalar  +.ps
      =/  number-system  ?:(?=(dime expr) -.expr type.expr)
      ?.  ?=(number-systems number-system)
        ~|  "{<number-system>} not a supported number system for %round, ".
            "need ?(~.rd ~.sd ~.ud)"
            !!
      =/  ps  %:  evaluate-datum  length:;;(round:ast scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      =/  len-expr=resolved-scalar  +.ps
      =/  len-type  ?:(?=(dime len-expr) -.len-expr type.len-expr)
      ?.  |(=(~.ud len-type) =(~.sd len-type))
        ~|  "round: length must be @ud or @sd, got {<len-type>}"  !!
      ::  extract [is-positive magnitude] from a raw length atom
      =/  extract-len-info
        |=  lval=@
        ^-  [? @ud]
        ?:  =(~.ud len-type)  [%.y lval]
        ?:  (syn:si `@s`lval)  [%.y (abs:si `@s`lval)]
        [%.n (abs:si `@s`lval)]
      ::  floor for @rd, returns raw @rd atom
      =/  floor-rd
        |=  x=@
        ^-  @
        =/  dat  `@rd`x
        =/  int  (san:rd (need (toi:rd dat)))
        =/  dcm  (sub:rd dat int)
        ?:  =(0 dcm)  `@`int
        ?:  (sig:rd dat)  `@`int
        `@`(sub:rd int .~1)
      ::  round @rd using round-half-up at decimal position by [is-pos mag]
      ::  positive mag: round to mag decimal places (e.g. mag=2: 1.456 -> 1.46)
      ::  negative mag (is-pos=%.n): round before decimal
      ::    (e.g. mag=1: 123.4 -> 120.0)
      =/  round-rd
        |=  [datum=@ is-pos=? mag=@ud]
        ^-  @
        =/  dat    `@rd`datum
        =/  scale  (~(pow rd:math [%z .~1e-15]) .~10 (sun:rd mag))
        =/  scaled  ?:  is-pos
                      (mul:rd dat scale)
                    (div:rd dat scale)
        =/  floored  `@rd`(floor-rd `@`(add:rd scaled .~0.5))
        ?:  is-pos
          `@`(div:rd floored scale)
        `@`(mul:rd floored scale)
      ::  round @s (signed integer) using round-half-up toward +infinity
      ::  positive mag: no-op (integers have no fractional part)
      ::  negative mag: round to nearest 10^mag using floor-division
      =/  round-sd
        |=  [datum=@ is-pos=? mag=@ud]
        ^-  @
        ?:  is-pos  datum
        =/  scale  (pow 10 mag)
        =/  half   (sun:si (div scale 2))
        =/  scl    (sun:si scale)
        =/  shifted  (sum:si `@s`datum half)
        =/  q  (fra:si shifted scl)
        =/  r  (rem:si shifted scl)
        ?:  !(syn:si r)
          `@`(pro:si (dif:si q --1) scl)
        `@`(pro:si q scl)
      ::  round @ud using round-half-up
      ::  positive mag: no-op; negative mag: round to nearest 10^mag
      =/  round-ud
        |=  [datum=@ is-pos=? mag=@ud]
        ^-  @
        ?:  is-pos  datum
        =/  scale  (pow 10 mag)
        =/  half   (div scale 2)
        (mul (div (add `@ud`datum half) scale) scale)
      ?:  ?=(dime expr)
        :-  seed
            ?-  number-system
                ::
                %rd
                  ?.  ?=(dime len-expr)
                    :+  %fn  number-system
                    |=  =data-row
                    ^-  dime
                    =/  [is-pos=? mag=@ud]
                          (extract-len-info +:(f.len-expr data-row))
                    [number-system (round-rd +.expr is-pos mag)]
                  =/  [is-pos=? mag=@ud]  (extract-len-info +.len-expr)
                  [number-system (round-rd +.expr is-pos mag)]
                ::
                %sd
                  ?.  ?=(dime len-expr)
                    :+  %fn  number-system
                    |=  =data-row
                    ^-  dime
                    =/  [is-pos=? mag=@ud]
                          (extract-len-info +:(f.len-expr data-row))
                    [number-system (round-sd +.expr is-pos mag)]
                  =/  [is-pos=? mag=@ud]  (extract-len-info +.len-expr)
                  [number-system (round-sd +.expr is-pos mag)]
                ::
                %ud
                  ?.  ?=(dime len-expr)
                    :+  %fn  number-system
                    |=  =data-row
                    ^-  dime
                    =/  [is-pos=? mag=@ud]
                          (extract-len-info +:(f.len-expr data-row))
                    [number-system (round-ud +.expr is-pos mag)]
                  =/  [is-pos=? mag=@ud]  (extract-len-info +.len-expr)
                  [number-system (round-ud +.expr is-pos mag)]
                ==
      :-  seed
      :+  %fn
        type.expr
        |=  =data-row
        ^-  dime
        =/  datum  +:(f.expr data-row)
        =/  len    ?:(?=(dime len-expr) +.len-expr +:(f.len-expr data-row))
        =/  [is-pos=? mag=@ud]  (extract-len-info len)
        ?-  number-system
            %rd  [number-system (round-rd datum is-pos mag)]
            %sd  [number-system (round-sd datum is-pos mag)]
            %ud  [number-system (round-ud datum is-pos mag)]
            ==
  ::
    %sign
      =/  ps  %:  evaluate-datum  numeric-expression:;;(sign:ast scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      =/  expr=resolved-scalar  +.ps
      =/  number-system  ?:(?=(dime expr) -.expr type.expr)
      ?.  ?=(number-systems number-system)
        ~|  "{<number-system>} not a supported number system for %sign, ".
            "need ?(~.rd ~.sd ~.ud)"
            !!
      ?:  ?=(dime expr)
        :-  seed
        ?-  number-system
            ::
            %rd
              ?:  =(0 +.expr)
                   [number-system 0]
              ?:  (sig:rd +.expr)
                 [number-system .~1]
              [number-system .~-1]
            ::
            %sd
              ?:  =(0 +.expr)
                   [number-system 0]
              ?:  (syn:si +.expr)
                 [number-system --1]
              [number-system -1]
            ::
            %ud
              ?:  =(0 +.expr)
                [number-system 0]
              [number-system 1]
            ==
      :-  seed
      :+  %fn
        type.expr
        |=  =data-row
        ^-  dime
        ?-  number-system
            ::
            %rd
              =/  datum  +:(f.expr data-row)
              ?:  =(0 datum)
                   [number-system 0]
              ?:  (sig:rd datum)
                 [number-system .~1]
              [number-system .~-1]
            ::
            %sd
              =/  datum  +:(f.expr data-row)
              ?:  =(0 datum)
                   [number-system 0]
              ?:  (syn:si datum)
                 [number-system --1]
              [number-system -1]
            ::
            %ud
              ?:  =(0 +:(f.expr data-row))
                [number-system 0]
              [number-system 1]
            ==
  ::
    %sqrt
      =/  ps  %:  evaluate-datum  float-expression:;;(sqrt:ast scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      =/  expr=resolved-scalar  +.ps
      =/  number-system  ?:(?=(dime expr) -.expr type.expr)
      ?.  ?=(number-systems number-system)
        ~|  "{<number-system>} not a supported number system for %sqrt, ".
            "need ?(~.rd ~.sd ~.ud)"
            !!
      ?:  ?=(dime expr)
        :-  seed
        ?-  number-system
            ::
            %rd
              ?:  =(0 +.expr)    [number-system 0]
              ?:  =(.~1 +.expr)  [number-system .~1]
              =/  result  (sqt:rd +.expr)
              ?~  (toi:rd result)
                ~|  "sqrt({<`@rd`+.expr>}) is not a number"  !!
              [number-system result]
            ::
            %sd
              ?:  =(0 +.expr)  [number-system 0]
              ?:  =(2 +.expr)  [number-system 2]  ::  @sd --1, sqrt(--1) = --1
              =/  toi-result  (toi:rd (sqt:rd (san:rd +.expr)))
              ?~  toi-result  ~|  "sqrt({<`@sd`+.expr>}) is not a number"  !!
              [number-system u.toi-result]
            ::
            %ud
              ?:  =(0 +.expr)  [number-system 0]
              ?:  =(1 +.expr)  [number-system 1]
              =/  toi-result  (toi:rd (sqt:rd (sun:rd +.expr)))
              ?~  toi-result  ~|  "sqrt({<+.expr>}) is not a number"  !!
              [number-system (abs:si u.toi-result)]
            ==
      :-  seed
      :+  %fn
        type.expr
        |=  =data-row
        ^-  dime
        ?-  number-system
            ::
            %rd
              =/  datum  +:(f.expr data-row)
              ?:  =(0 datum)    [number-system 0]
              ?:  =(.~1 datum)  [number-system .~1]
              =/  result  (sqt:rd datum)
              ?~  (toi:rd result)
                ~|  "sqrt({<`@rd`datum>}) is not a number"  !!
              [number-system result]
            ::
            %sd
              =/  datum  +:(f.expr data-row)
              ?:  =(0 datum)  [number-system 0]
              ?:  =(2 datum)  [number-system 2]  ::  @sd --1, sqrt(--1) = --1
              =/  toi-result  (toi:rd (sqt:rd (san:rd datum)))
              ?~  toi-result  ~|  "sqrt({<`@sd`datum>}) is not a number"  !!
              [number-system u.toi-result]
            ::
            %ud
              =/  datum  +:(f.expr data-row)
              ?:  =(0 datum)  [number-system 0]
              ?:  =(1 datum)  [number-system 1]
              =/  toi-result  (toi:rd (sqt:rd (sun:rd datum)))
              ?~  toi-result  ~|  "sqrt({<datum>}) is not a number"  !!
              [number-system (abs:si u.toi-result)]
            ==
  ::
  ::  string functions
  ::
    %concat
      ::  CONCAT(str1, str2, ...) returns the concatenation of string arguments
      =/  exprs
        %+  turn  ;;((list scalar-node) args:;;(concat:ast scalar))
        |=  arg=*
        =/  ps  %:  evaluate-datum  arg
                                    named-ctes
                                    qualifier-lookup
                                    map-meta
                                    resolved-scalars
                                    bowl
                                    seed
                                    ==
        +.ps
      ?>  (levy exprs |=(e=resolved-scalar =(~.t ?:(?=(dime e) -.e type.e))))
      ?:  (levy exprs |=(e=resolved-scalar ?=(dime e)))
        :-  seed
        :-  ~.t
            %-  crip  %-  zing  %+  turn  exprs
                                          |=  e=resolved-scalar
                                          (trip `@t`+:;;(dime e))
      :-  seed
      :+  %fn  ~.t
      |=  =data-row
      ^-  dime
      :-  ~.t
            %-  crip  %-  zing
                            %+  turn
                                  exprs
                                  |=  e=resolved-scalar
                                  ::(trip `@t`+:?:(?=(dime e) e (f.e data-row)))
                                  %-  trip  ^-  @t
                                            ?:  ?=(dime e)  +.e
                                            +:(f.e data-row)
  ::
    %left
      ::  LEFT(str, n) returns the leftmost n characters of str
      =/  ps  %:  evaluate-datum  string-expression:;;(left:ast scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      =/  str-expr=resolved-scalar  +.ps
      =/  ps  %:  evaluate-datum  integer-expression:;;(left:ast scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      =/  int-expr=resolved-scalar  +.ps
      ?.  =(~.t ?:(?=(dime str-expr) -.str-expr type.str-expr))
        ~|  "LEFT: expected @t string, got ".
            "{<?:(?=(dime str-expr) -.str-expr type.str-expr)>}"
            !!
      ?.  =(~.ud ?:(?=(dime int-expr) -.int-expr type.int-expr))
        ~|  "LEFT: expected @ud integer, got ".
            "{<?:(?=(dime int-expr) -.int-expr type.int-expr)>}"
            !!
      =/  do-left
        |=  [str=@t n=@ud]
        (crip (scag n (trip str)))
      ?:  &(?=(dime str-expr) ?=(dime int-expr))
        [seed [~.t (do-left `@t`+.str-expr `@ud`+.int-expr)]]
      :-  seed
      :+  %fn  ~.t
      |=  =data-row
      ^-  dime
      =/  str  `@t`+:?:(?=(dime str-expr) str-expr (f.str-expr data-row))
      =/  n    `@ud`+:?:(?=(dime int-expr) int-expr (f.int-expr data-row))
      [~.t (do-left str n)]
  ::
    %len
      ::  LEN(str) returns the number of characters as an unsigned integer
      =/  ps  %:  evaluate-datum  string-expression:;;(len:ast scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      =/  expr=resolved-scalar  +.ps
      ?.  =(~.t ?:(?=(dime expr) -.expr type.expr))
        ~|  "LEN: expected @t string, got ".
            "{<?:(?=(dime expr) -.expr type.expr)>}"
            !!
      ?:  ?=(dime expr)
        [seed [~.ud (met 3 `@t`+.expr)]]
      :-  seed
      :+  %fn  ~.ud
      |=  =data-row
      ^-  dime
      [~.ud (met 3 `@t`+:(f.expr data-row))]
  ::
    %lower
      ::  LOWER(str) converts all uppercase characters in str to lowercase
      =/  ps  %:  evaluate-datum  string-expression:;;(lower:ast scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      =/  expr=resolved-scalar  +.ps
      ?.  =(~.t ?:(?=(dime expr) -.expr type.expr))
        ~|  "LOWER: expected @t string, got ".
            "{<?:(?=(dime expr) -.expr type.expr)>}"
            !!
      ?:  ?=(dime expr)
        [seed [~.t (crip (cass (trip `@t`+.expr)))]]
      :-  seed
      :+  %fn  ~.t
      |=  =data-row
      ^-  dime
      [~.t (crip (cass (trip `@t`+:(f.expr data-row))))]
  ::
    %ltrim
      ::  LTRIM(str[, pattern]) removes leading whitespace (default)
      ::                        or leading occurrences of pattern
      =/  ps  %:  evaluate-datum  string-expression:;;(ltrim:ast scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      =/  str-expr=resolved-scalar  +.ps
      ?.  =(~.t ?:(?=(dime str-expr) -.str-expr type.str-expr))
        ~|  "LTRIM: expected @t string, got ".
            "{<?:(?=(dime str-expr) -.str-expr type.str-expr)>}"
            !!
      =/  raw-pattern  pattern:;;(ltrim:ast scalar)
      =/  is-ws
        |=  c=@t
        ?|  =(c ' ')  =(c '\09')  =(c '\0d')  ==
      =/  drop-ws
        |=  t=tape
        |-  ^-  tape
        ?~  t  ~
        ?.  (is-ws i.t)  t
        $(t t.t)
      =/  drop-pat
        |=  [p=tape s=tape]
        ^-  tape
        ?~  p  s
        =/  n=@ud  (lent p)
        |-  ^-  tape
        ?.  =(p (scag n s))  s
        $(s (slag n s))
      =/  do-ltrim-ws
        |=  str=@t
        ^-  @t
        (crip (drop-ws (trip str)))
      =/  do-ltrim-pat
        |=  [str=@t pat=@t]
        ^-  @t
        (crip (drop-pat (trip pat) (trip str)))
      ?~  raw-pattern
        ?:  ?=(dime str-expr)
          [seed [~.t (do-ltrim-ws `@t`+.str-expr)]]
        :-  seed
        :+  %fn  ~.t
        |=  =data-row
        ^-  dime
        [~.t (do-ltrim-ws `@t`+:(f.str-expr data-row))]
      =/  ps  %:  evaluate-datum  u.raw-pattern
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      =/  pat-expr=resolved-scalar  +.ps
      ?.  =(~.t ?:(?=(dime pat-expr) -.pat-expr type.pat-expr))
        ~|  "LTRIM: expected @t pattern, got ".
            "{<?:(?=(dime pat-expr) -.pat-expr type.pat-expr)>}"
            !!
      ?:  &(?=(dime str-expr) ?=(dime pat-expr))
        [seed [~.t (do-ltrim-pat `@t`+.str-expr `@t`+.pat-expr)]]
      :-  seed
      :+  %fn  ~.t
      |=  =data-row
      ^-  dime
      =/  str  `@t`+:?:(?=(dime str-expr) str-expr (f.str-expr data-row))
      =/  pat  `@t`+:?:(?=(dime pat-expr) pat-expr (f.pat-expr data-row))
      [~.t (do-ltrim-pat str pat)]
  ::
    %patindex
      ::  PATINDEX(str, pattern) returns 1-based starting position of pattern
      ::                         in str, or 0 if not found
      =/  ps
            %:  evaluate-datum  string-expression:;;(patindex:ast scalar)
                                named-ctes
                                qualifier-lookup
                                map-meta
                                resolved-scalars
                                bowl
                                seed
                                ==
      =.  seed  -.ps
      =/  str-expr=resolved-scalar  +.ps
      =/  ps  %:  evaluate-datum  pattern:;;(patindex:ast scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      =/  pat-expr=resolved-scalar  +.ps
      ?.  =(~.t ?:(?=(dime str-expr) -.str-expr type.str-expr))
        ~|  "PATINDEX: expected @t string, got ".
            "{<?:(?=(dime str-expr) -.str-expr type.str-expr)>}"
            !!
      ?.  =(~.t ?:(?=(dime pat-expr) -.pat-expr type.pat-expr))
        ~|  "PATINDEX: expected @t pattern, got ".
            "{<?:(?=(dime pat-expr) -.pat-expr type.pat-expr)>}"
            !!
      =/  do-patindex
        |=  [str=@t pat=@t]
        ^-  @ud
        =/  pos  (find (trip pat) (trip str))
        ?~  pos  0
        +(u.pos)
      ?:  &(?=(dime str-expr) ?=(dime pat-expr))
        [seed [~.ud (do-patindex `@t`+.str-expr `@t`+.pat-expr)]]
      :-  seed
      :+  %fn  ~.ud
      |=  =data-row
      ^-  dime
      =/  str  `@t`+:?:(?=(dime str-expr) str-expr (f.str-expr data-row))
      =/  pat  `@t`+:?:(?=(dime pat-expr) pat-expr (f.pat-expr data-row))
      [~.ud (do-patindex str pat)]
  ::
    %quotestring
      ::  QUOTESTRING(str[, open, close]) wraps str in delimiters;
      ::                                  default delimiters are '[' and ']'
      =/  ps
            %:  evaluate-datum  string-expression:;;(quotestring:ast scalar)
                                named-ctes
                                qualifier-lookup
                                map-meta
                                resolved-scalars
                                bowl
                                seed
                                ==
      =.  seed  -.ps
      =/  str-expr=resolved-scalar  +.ps
      ?.  =(~.t ?:(?=(dime str-expr) -.str-expr type.str-expr))
        ~|  "QUOTESTRING: expected @t string, got ".
            "{<?:(?=(dime str-expr) -.str-expr type.str-expr)>}"
            !!
      =/  raw-quote  quote:;;(quotestring:ast scalar)
      =/  do-quote
        |=  [str=@t open=@t close=@t]
        ^-  @t
        (crip (weld (weld (trip open) (trip str)) (trip close)))
      ?~  raw-quote
        ?:  ?=(dime str-expr)
          [seed [~.t (do-quote `@t`+.str-expr '[' ']')]]
        :-  seed
        :+  %fn  ~.t
        |=  =data-row
        ^-  dime
        [~.t (do-quote `@t`+:(f.str-expr data-row) '[' ']')]
      =/  ps   %:  evaluate-datum  -.u.raw-quote
                                   named-ctes
                                   qualifier-lookup
                                   map-meta
                                   resolved-scalars
                                   bowl
                                   seed
                                   ==
      =.  seed  -.ps
      =/  open-expr=resolved-scalar  +.ps
      =/  ps  %:  evaluate-datum  +.u.raw-quote
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      =/  close-expr=resolved-scalar  +.ps
      ?.  =(~.t ?:(?=(dime open-expr) -.open-expr type.open-expr))
        ~|  "QUOTESTRING: expected @t open, got ".
            "{<?:(?=(dime open-expr) -.open-expr type.open-expr)>}"
            !!
      ?.  =(~.t ?:(?=(dime close-expr) -.close-expr type.close-expr))
        ~|  "QUOTESTRING: expected @t close, got ".
            "{<?:(?=(dime close-expr) -.close-expr type.close-expr)>}"
            !!
      ?:  &(?=(dime str-expr) &(?=(dime open-expr) ?=(dime close-expr)))
        [seed [~.t (do-quote `@t`+.str-expr `@t`+.open-expr `@t`+.close-expr)]]
      :-  seed
      :+  %fn  ~.t
      |=  =data-row
      ^-  dime
      =/  str    `@t`+:?:(?=(dime str-expr) str-expr (f.str-expr data-row))
      =/  open   `@t`+:?:(?=(dime open-expr) open-expr (f.open-expr data-row))
      =/  close
            `@t`+:?:(?=(dime close-expr) close-expr (f.close-expr data-row))
      [~.t (do-quote str open close)]
  ::
    %replace
      ::  REPLACE(str, pattern, replacement) replaces all occurrences of pattern
      ::                                     in str with replacement
      =/  ps  %:  evaluate-datum  string-expression:;;(replace:ast scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      =/  str-expr=resolved-scalar  +.ps
      =/  ps  %:  evaluate-datum  pattern:;;(replace:ast scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      =/  pat-expr=resolved-scalar  +.ps
      =/  ps  %:  evaluate-datum  replacement:;;(replace:ast scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      =/  rep-expr=resolved-scalar  +.ps
      ?.  =(~.t ?:(?=(dime str-expr) -.str-expr type.str-expr))
        ~|  "REPLACE: expected @t string, got ".
            "{<?:(?=(dime str-expr) -.str-expr type.str-expr)>}"
            !!
      ?.  =(~.t ?:(?=(dime pat-expr) -.pat-expr type.pat-expr))
        ~|  "REPLACE: expected @t pattern, got ".
            "{<?:(?=(dime pat-expr) -.pat-expr type.pat-expr)>}"
            !!
      ?.  =(~.t ?:(?=(dime rep-expr) -.rep-expr type.rep-expr))
        ~|  "REPLACE: expected @t replacement, got ".
            "{<?:(?=(dime rep-expr) -.rep-expr type.rep-expr)>}"
            !!
      =/  do-replace
        |=  [str=@t pat=@t rep=@t]
        ^-  @t
        =/  p=tape  (trip pat)
        =/  r=tape  (trip rep)
        =/  n=@ud   (lent p)
        =/  s=tape  (trip str)
        =/  result=tape
          ?~  p  s
          |-  ^-  tape
          ?~  s  ~
          ?.  =(p (scag n `tape`s))
            [i.s $(s t.s)]
          (weld r $(s (slag n `tape`s)))
        (crip result)
      ?:  &(?=(dime str-expr) &(?=(dime pat-expr) ?=(dime rep-expr)))
        [seed [~.t (do-replace `@t`+.str-expr `@t`+.pat-expr `@t`+.rep-expr)]]
      :-  seed
      :+  %fn  ~.t
      |=  =data-row
      ^-  dime
      =/  str  `@t`+:?:(?=(dime str-expr) str-expr (f.str-expr data-row))
      =/  pat  `@t`+:?:(?=(dime pat-expr) pat-expr (f.pat-expr data-row))
      =/  rep  `@t`+:?:(?=(dime rep-expr) rep-expr (f.rep-expr data-row))
      [~.t (do-replace str pat rep)]
  ::
    %replicate
      ::  REPLICATE(str, n) repeats str n times
      =/  ps
            %:  evaluate-datum  string-expression:;;(replicate:ast scalar)
                                named-ctes
                                qualifier-lookup
                                map-meta
                                resolved-scalars
                                bowl
                                seed
                                ==
      =.  seed  -.ps
      =/  str-expr=resolved-scalar  +.ps
      =/  ps
            %:  evaluate-datum  integer-expression:;;(replicate:ast scalar)
                                named-ctes
                                qualifier-lookup
                                map-meta
                                resolved-scalars
                                bowl
                                seed
                                ==
      =.  seed  -.ps
      =/  int-expr=resolved-scalar  +.ps
      ?.  =(~.t ?:(?=(dime str-expr) -.str-expr type.str-expr))
        ~|  "REPLICATE: expected @t string, got ".
            "{<?:(?=(dime str-expr) -.str-expr type.str-expr)>}"
            !!
      ?.  =(~.ud ?:(?=(dime int-expr) -.int-expr type.int-expr))
        ~|  "REPLICATE: expected @ud integer, got ".
            "{<?:(?=(dime int-expr) -.int-expr type.int-expr)>}"
            !!
      =/  do-replicate
        |=  [str=@t n=@ud]
        ^-  @t
        =/  s=tape  (trip str)
        =/  result=tape
          |-  ^-  tape
          ?:  =(n 0)  ~
          (weld s $(n (dec n)))
        (crip result)
      ?:  &(?=(dime str-expr) ?=(dime int-expr))
        [seed [~.t (do-replicate `@t`+.str-expr `@ud`+.int-expr)]]
      :-  seed
      :+  %fn  ~.t
      |=  =data-row
      ^-  dime
      =/  str  `@t`+:?:(?=(dime str-expr) str-expr (f.str-expr data-row))
      =/  n    `@ud`+:?:(?=(dime int-expr) int-expr (f.int-expr data-row))
      [~.t (do-replicate str n)]
  ::
    %reverse
      ::  REVERSE(str) returns the characters of str in reverse order
      =/  ps  %:  evaluate-datum  string-expression:;;(reverse:ast scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      =/  expr=resolved-scalar  +.ps
      ?.  =(~.t ?:(?=(dime expr) -.expr type.expr))
        ~|  "REVERSE: expected @t string, got ".
            "{<?:(?=(dime expr) -.expr type.expr)>}"
            !!
      ?:  ?=(dime expr)
        [seed [~.t (crip (flop (trip `@t`+.expr)))]]
      :-  seed
      :+  %fn  ~.t
      |=  =data-row
      ^-  dime
      [~.t (crip (flop (trip `@t`+:(f.expr data-row))))]
  ::
    %right
      ::  RIGHT(str, n) returns the rightmost n characters of str
      =/  ps  %:  evaluate-datum  string-expression:;;(right:ast scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      =/  str-expr=resolved-scalar  +.ps
      =/  ps  %:  evaluate-datum  integer-expression:;;(right:ast scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      =/  int-expr=resolved-scalar  +.ps
      ?.  =(~.t ?:(?=(dime str-expr) -.str-expr type.str-expr))
        ~|  "RIGHT: expected @t string, got ".
            "{<?:(?=(dime str-expr) -.str-expr type.str-expr)>}"
            !!
      ?.  =(~.ud ?:(?=(dime int-expr) -.int-expr type.int-expr))
        ~|  "RIGHT: expected @ud integer, got ".
            "{<?:(?=(dime int-expr) -.int-expr type.int-expr)>}"
            !!
      =/  do-right
        |=  [str=@t n=@ud]
        ^-  @t
        =/  s=tape  (trip str)
        =/  len=@ud  (lent s)
        (crip ?:((gte n len) s (slag (sub len n) s)))
      ?:  &(?=(dime str-expr) ?=(dime int-expr))
        [seed [~.t (do-right `@t`+.str-expr `@ud`+.int-expr)]]
      :-  seed
      :+  %fn  ~.t
      |=  =data-row
      ^-  dime
      =/  str  `@t`+:?:(?=(dime str-expr) str-expr (f.str-expr data-row))
      =/  n    `@ud`+:?:(?=(dime int-expr) int-expr (f.int-expr data-row))
      [~.t (do-right str n)]
  ::
    %rtrim
      ::  RTRIM(str[, pattern]) removes trailing whitespace (default)
      ::                        or trailing occurrences of pattern
      =/  ps  %:  evaluate-datum  string-expression:;;(rtrim:ast scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      =/  str-expr=resolved-scalar  +.ps
      ?.  =(~.t ?:(?=(dime str-expr) -.str-expr type.str-expr))
        ~|  "RTRIM: expected @t string, got ".
            "{<?:(?=(dime str-expr) -.str-expr type.str-expr)>}"
            !!
      =/  raw-pattern  pattern:;;(rtrim:ast scalar)
      =/  is-ws
        |=  c=@t
        ?|  =(c ' ')  =(c '\09')  =(c '\0d')  ==
      =/  drop-ws
        |=  t=tape
        |-  ^-  tape
        ?~  t  ~
        ?.  (is-ws i.t)  t
        $(t t.t)
      =/  drop-pat
        |=  [p=tape s=tape]
        ^-  tape
        ?~  p  s
        =/  n=@ud  (lent p)
        |-  ^-  tape
        ?.  =(p (scag n s))  s
        $(s (slag n s))
      =/  do-rtrim-ws
        |=  str=@t
        ^-  @t
        (crip (flop (drop-ws (flop (trip str)))))
      =/  do-rtrim-pat
        |=  [str=@t pat=@t]
        ^-  @t
        (crip (flop (drop-pat (flop (trip pat)) (flop (trip str)))))
      ?~  raw-pattern
        ?:  ?=(dime str-expr)
          [seed [~.t (do-rtrim-ws `@t`+.str-expr)]]
        :-  seed
        :+  %fn  ~.t
        |=  =data-row
        ^-  dime
        [~.t (do-rtrim-ws `@t`+:(f.str-expr data-row))]
      =/  ps  %:  evaluate-datum  u.raw-pattern
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      =/  pat-expr=resolved-scalar  +.ps
      ?.  =(~.t ?:(?=(dime pat-expr) -.pat-expr type.pat-expr))
        ~|  "RTRIM: expected @t pattern, got ".
            "{<?:(?=(dime pat-expr) -.pat-expr type.pat-expr)>}"
            !!
      ?:  &(?=(dime str-expr) ?=(dime pat-expr))
        [seed [~.t (do-rtrim-pat `@t`+.str-expr `@t`+.pat-expr)]]
      :-  seed
      :+  %fn  ~.t
      |=  =data-row
      ^-  dime
      =/  str  `@t`+:?:(?=(dime str-expr) str-expr (f.str-expr data-row))
      =/  pat  `@t`+:?:(?=(dime pat-expr) pat-expr (f.pat-expr data-row))
      [~.t (do-rtrim-pat str pat)]
  ::
    %string
      ::  STRING(numeric) converts a numeric value to its string representation
      =/  ps  %:  evaluate-datum  numeric-expression:;;(string:ast scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      =/  expr=resolved-scalar  +.ps
      ?:  ?=(dime expr)
        [seed [~.t (crip (scow `@tas`-.expr +.expr))]]
      :-  seed
      :+  %fn  ~.t
      |=  =data-row
      ^-  dime
      =/  d  (f.expr data-row)
      [~.t (crip (scow `@tas`-.d +.d))]
  ::
    %string-concat
      ::  STRING-CONCAT(str1, str2, ..., delimiter) joins strings with delimiter
      =/  arg-exprs
        %+  turn  ;;((list scalar-node) args:;;(string-concat:ast scalar))
        |=  arg=*
        =/  ps  %:  evaluate-datum  arg
                                    named-ctes
                                    qualifier-lookup
                                    map-meta
                                    resolved-scalars
                                    bowl
                                    seed
                                    ==
        +.ps
      =/  ps  %:  evaluate-datum  delimiter:;;(string-concat:ast scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      =/  delim-expr=resolved-scalar  +.ps
      ?>  (levy arg-exprs |=(e=resolved-scalar =(~.t ?:(?=(dime e) -.e type.e))))
      ?.  =(~.t ?:(?=(dime delim-expr) -.delim-expr type.delim-expr))
        ~|  "STRING-CONCAT: expected @t delimiter, got ".
            "{<?:(?=(dime delim-expr) -.delim-expr type.delim-expr)>}"
            !!
      =/  do-join
        |=  [tapes=(list tape) d=tape]
        ^-  tape
        |-  ^-  tape
        ?~  tapes  ~
        ?~  t.tapes  i.tapes
        (weld i.tapes (weld d $(tapes t.tapes)))
      ?:  ?&  (levy arg-exprs |=(e=resolved-scalar ?=(dime e)))
              ?=(dime delim-expr)
              ==
        :-  seed
        :-  ~.t
            =/  tapes
              (turn arg-exprs |=(e=resolved-scalar (trip `@t`+:;;(dime e))))
            =/  d      (trip `@t`+:;;(dime delim-expr))
            (crip (do-join tapes d))
      :-  seed
      :+  %fn  ~.t
      |=  =data-row
      ^-  dime
      =/  tapes  %+  turn  arg-exprs
                 |=  e=resolved-scalar
                 %-  trip  ^-  @t
                          ?:  ?=(dime e)  +.e
                          +:(f.e data-row)
      =/  d
            %-  trip
                `@t`+:?:(?=(dime delim-expr) delim-expr (f.delim-expr data-row))
      [~.t (crip (do-join tapes d))]
  ::
    %stuff
      ::  STUFF(str, start, length, replace) deletes length chars at start
      ::                                     (1-based) and inserts replace
      =/  ps  %:  evaluate-datum  string-expression:;;(stuff:ast scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      =/  str-expr=resolved-scalar  +.ps
      =/  ps  %:  evaluate-datum  start:;;(stuff:ast scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      =/  start-expr=resolved-scalar  +.ps
      =/  ps  %:  evaluate-datum  length:;;(stuff:ast scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      =/  len-expr=resolved-scalar  +.ps
      =/  ps  %:  evaluate-datum  replace:;;(stuff:ast scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      =/  rep-expr=resolved-scalar  +.ps
      ?.  =(~.t ?:(?=(dime str-expr) -.str-expr type.str-expr))
        ~|  "STUFF: expected @t string, got ".
            "{<?:(?=(dime str-expr) -.str-expr type.str-expr)>}"
            !!
      ?.  =(~.ud ?:(?=(dime start-expr) -.start-expr type.start-expr))
        ~|  "STUFF: expected @ud start, got ".
            "{<?:(?=(dime start-expr) -.start-expr type.start-expr)>}"
            !!
      ?.  =(~.ud ?:(?=(dime len-expr) -.len-expr type.len-expr))
        ~|  "STUFF: expected @ud length, got ".
            "{<?:(?=(dime len-expr) -.len-expr type.len-expr)>}"
            !!
      ?.  =(~.t ?:(?=(dime rep-expr) -.rep-expr type.rep-expr))
        ~|  "STUFF: expected @t replacement, got ".
            "{<?:(?=(dime rep-expr) -.rep-expr type.rep-expr)>}"
            !!
      =/  do-stuff
        |=  [str=@t start=@ud len=@ud rep=@t]
        ^-  @t
        =/  s=tape   (trip str)
        =/  r=tape   (trip rep)
        =/  idx=@ud  (dec start)
        (crip (weld (scag idx s) (weld r (slag (add idx len) s))))
      ?:  ?&  ?=(dime str-expr)
              &(?=(dime start-expr) &(?=(dime len-expr) ?=(dime rep-expr)))
              ==
        :-  seed
        :-  ~.t
            %:  do-stuff  `@t`+.str-expr
                          `@ud`+.start-expr
                          `@ud`+.len-expr
                          `@t`+.rep-expr
                          ==
      :-  seed
      :+  %fn  ~.t
      |=  =data-row
      ^-  dime
      =/  str    `@t`+:?:(?=(dime str-expr) str-expr (f.str-expr data-row))
      =/  start
            `@ud`+:?:(?=(dime start-expr) start-expr (f.start-expr data-row))
      =/  len    `@ud`+:?:(?=(dime len-expr) len-expr (f.len-expr data-row))
      =/  rep    `@t`+:?:(?=(dime rep-expr) rep-expr (f.rep-expr data-row))
      [~.t (do-stuff str start len rep)]
  ::
    %substring
      ::  SUBSTRING(str, start[, length]) returns substring starting
      ::                                  at start (1-based index);
      ::  if length is omitted, returns from start to end of str
      =/  ps
            %:  evaluate-datum  string-expression:;;(substring:ast scalar)
                                named-ctes
                                qualifier-lookup
                                map-meta
                                resolved-scalars
                                bowl
                                seed
                                ==
      =.  seed  -.ps
      =/  str-expr=resolved-scalar  +.ps
      =/  ps  %:  evaluate-datum  start:;;(substring:ast scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      =/  start-expr=resolved-scalar  +.ps
      ?.  =(~.t ?:(?=(dime str-expr) -.str-expr type.str-expr))
        ~|  "SUBSTRING: expected @t string, got ".
            "{<?:(?=(dime str-expr) -.str-expr type.str-expr)>}"
            !!
      ?.  =(~.ud ?:(?=(dime start-expr) -.start-expr type.start-expr))
        ~|  "SUBSTRING: expected @ud integer, got ".
            "{<?:(?=(dime start-expr) -.start-expr type.start-expr)>}"
            !!
      =/  raw-length  length:;;(substring:ast scalar)
      =/  do-sub
        |=  [str=@t start=@ud mlen=(unit @ud)]
        ^-  @t
        =/  from=tape  (slag (dec start) (trip str))
        ?~  mlen
          (crip from)
        (crip (scag u.mlen from))
      ?~  raw-length
        ?:  &(?=(dime str-expr) ?=(dime start-expr))
          [seed [~.t (do-sub `@t`+.str-expr `@ud`+.start-expr ~)]]
        :-  seed
        :+  %fn  ~.t
        |=  =data-row
        ^-  dime
        =/  str    `@t`+:?:(?=(dime str-expr) str-expr (f.str-expr data-row))
        =/  start
              `@ud`+:?:(?=(dime start-expr) start-expr (f.start-expr data-row))
        [~.t (do-sub str start ~)]
      =/  ps  %:  evaluate-datum  u.raw-length
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      =/  len-expr=resolved-scalar  +.ps
      ?.  =(~.ud ?:(?=(dime len-expr) -.len-expr type.len-expr))
        ~|  "SUBSTRING: expected @ud length, got ".
            "{<?:(?=(dime len-expr) -.len-expr type.len-expr)>}"
            !!
      ?:  &(?=(dime str-expr) &(?=(dime start-expr) ?=(dime len-expr)))
        [seed [~.t (do-sub `@t`+.str-expr `@ud`+.start-expr (some `@ud`+.len-expr))]]
      :-  seed
      :+  %fn  ~.t
      |=  =data-row
      ^-  dime
      =/  str    `@t`+:?:(?=(dime str-expr) str-expr (f.str-expr data-row))
      =/  start
            `@ud`+:?:(?=(dime start-expr) start-expr (f.start-expr data-row))
      =/  len    `@ud`+:?:(?=(dime len-expr) len-expr (f.len-expr data-row))
      [~.t (do-sub str start (some len))]
  ::
    %trim
      ::  TRIM(str[, pattern]) removes leading and trailing whitespace
      ::                       or pattern occurrences from str
      =/  ps  %:  evaluate-datum  string-expression:;;(trim:ast scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      =/  str-expr=resolved-scalar  +.ps
      ?.  =(~.t ?:(?=(dime str-expr) -.str-expr type.str-expr))
        ~|  "TRIM: expected @t string, got ".
            "{<?:(?=(dime str-expr) -.str-expr type.str-expr)>}"
            !!
      =/  raw-pattern  pattern:;;(trim:ast scalar)
      =/  is-ws
        |=  c=@t
        ?|  =(c ' ')  =(c '\09')  =(c '\0d')  ==
      =/  drop-ws
        |=  t=tape
        |-  ^-  tape
        ?~  t  ~
        ?.  (is-ws i.t)  t
        $(t t.t)
      =/  drop-pat
        |=  [p=tape s=tape]
        ^-  tape
        ?~  p  s
        =/  n=@ud  (lent p)
        |-  ^-  tape
        ?.  =(p (scag n s))  s
        $(s (slag n s))
      =/  do-trim-ws
        |=  str=@t
        ^-  @t
        (crip (flop (drop-ws (flop (drop-ws (trip str))))))
      =/  do-trim-pat
        |=  [str=@t pat=@t]
        ^-  @t
        =/  p=tape  (trip pat)
        (crip (flop (drop-pat (flop p) (flop (drop-pat p (trip str))))))
      ?~  raw-pattern
        ?:  ?=(dime str-expr)
          [seed [~.t (do-trim-ws `@t`+.str-expr)]]
        :-  seed
        :+  %fn  ~.t
        |=  =data-row
        ^-  dime
        [~.t (do-trim-ws `@t`+:(f.str-expr data-row))]
      =/  ps  %:  evaluate-datum  u.raw-pattern
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      =/  pat-expr=resolved-scalar  +.ps
      ?.  =(~.t ?:(?=(dime pat-expr) -.pat-expr type.pat-expr))
        ~|  "TRIM: expected @t pattern, got ".
            "{<?:(?=(dime pat-expr) -.pat-expr type.pat-expr)>}"
            !!
      ?:  &(?=(dime str-expr) ?=(dime pat-expr))
        [seed [~.t (do-trim-pat `@t`+.str-expr `@t`+.pat-expr)]]
      :-  seed
      :+  %fn  ~.t
      |=  =data-row
      ^-  dime
      =/  str  `@t`+:?:(?=(dime str-expr) str-expr (f.str-expr data-row))
      =/  pat  `@t`+:?:(?=(dime pat-expr) pat-expr (f.pat-expr data-row))
      [~.t (do-trim-pat str pat)]
  ::
    %upper
      ::  UPPER(str) converts all lowercase characters in str to uppercase
      =/  ps  %:  evaluate-datum  string-expression:;;(upper:ast scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  seed
                                  ==
      =.  seed  -.ps
      =/  expr=resolved-scalar  +.ps
      ?.  =(~.t ?:(?=(dime expr) -.expr type.expr))
        ~|  "UPPER: expected @t string, got ".
            "{<?:(?=(dime expr) -.expr type.expr)>}"
            !!
      ?:  ?=(dime expr)
        [seed [~.t (crip (cuss (trip `@t`+.expr)))]]
      :-  seed
      :+  %fn  ~.t
      |=  =data-row
      ^-  dime
      [~.t (crip (cuss (trip `@t`+:(f.expr data-row))))]
  ::
  ==
::
++  prepare-if-then-else
  |=  $:  scalar=if-then-else:ast
          =named-ctes
          =qualifier-lookup
          =map-meta
          =resolved-scalars
          =bowl:gall
          ==
  ^-  resolved-scalar
  :: prepare-predicate switches on map-meta to evaluate its arguments
  :: (so if it gets a qualified lookup type it will expect qualified
  :: columns, and same for unqual)  however we can have cases when we have
  :: a predicate with unqualified columns but scalar return values that
  :: are qualified, thus this function would need to have two lookup
  :: types? one for the predicate and one for the arguments. To simplify
  :: for now we always raise the predicates to qualified columns
  =/  then=resolved-scalar
    %-  tail  %:  evaluate-datum  then.scalar
                        named-ctes
                        qualifier-lookup
                        map-meta
                        resolved-scalars
                        bowl
                        *seed
                        ==
  =/  else=resolved-scalar
    %-  tail  %:  evaluate-datum  else.scalar
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  *seed
                                  ==
  =/  [typ=@ta validated=(list resolved-scalar)]
    %:  check-consistent-types
        ~[then else]
        ~
        named-ctes
        map-meta
        resolved-scalars
        ==
  =/  pred-result
        %:  prepare-predicate  %+  normalize-predicate  if.scalar
                                                        qualifier-lookup
                               map-meta
                               qualifier-lookup
                               named-ctes
                               resolved-scalars
                               ==
  :+  %fn
      typ
      |=  =data-row
      ^-  dime
      =/  resolved  ?:((pred-result data-row) then else)
      ?:  ?=(dime resolved)  resolved
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
          =resolved-scalars
          =bowl:gall
          ==
  ^-  resolved-scalar
  ?~  target.scalar
    %:  prepare-case-searched  scalar
                               named-ctes
                               qualifier-lookup
                               map-meta
                               resolved-scalars
                               bowl
                               ==
  %:  prepare-case-simple  scalar
                           named-ctes
                           qualifier-lookup
                           map-meta
                           resolved-scalars
                           bowl
                           ==
::
++  prepare-case-searched
  ::  searched form: CASE WHEN <predicate> THEN ... END
  |=  $:  scalar=case:ast
          =named-ctes
          =qualifier-lookup
          =map-meta
          =resolved-scalars
          =bowl:gall
          ==
  ^-  resolved-scalar
  =/  cases  cases.scalar
  ?~  cases  ~|("cases can't be empty" !!)
  ::  check all then-values and else share a common type; capture return type
  =/  then-dos
    %+  turn  cases
    |=  cwt=case-when-then:ast
    %-  tail  %:  evaluate-datum  then.cwt
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  *seed
                                  ==
  =/  [typ=@ta validated=(list resolved-scalar)]
    %:  check-consistent-types
      ?~  else.scalar  then-dos
      :-  %-  tail  %:  evaluate-datum  (need else.scalar)
                                        named-ctes
                                        qualifier-lookup
                                        map-meta
                                        resolved-scalars
                                        bowl
                                        *seed
                                        ==
          then-dos
      ~
      named-ctes
      map-meta
      resolved-scalars
      ==
  =/  fns-to-apply  %:  case-searched-fns  scalar
                                           named-ctes
                                           qualifier-lookup
                                           map-meta
                                           resolved-scalars
                                           bowl
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
          =resolved-scalars
          =bowl:gall
          ==
  ^-  resolved-scalar
  =/  cases  cases.scalar
  ?~  cases  ~|("cases can't be empty" !!)
  ::  check that target and all when-values share a common type
  =/  when-dos
    %+  turn  cases
    |=  cwt=case-when-then:ast
    ?:  ?=(ops-and-conjs:ast -.when.cwt)
      ~|("when predicate not allowed in simple case" !!)
    %-  tail  %:  evaluate-datum  ;;(scalar-node when.cwt)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  *seed
                                  ==
  =/  target=resolved-scalar
    %-  tail  %:  evaluate-datum  (need target.scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  *seed
                                  ==
  =/  [cmp-typ=@ta cmp-valid=(list resolved-scalar)]
    %:  check-consistent-types
      [target when-dos]
      ~
      named-ctes
      map-meta
      resolved-scalars
      ==
  ::  check all then-values and else share a common type; capture return type
  =/  then-dos
    %+  turn  cases
    |=  cwt=case-when-then:ast
    %-  tail  %:  evaluate-datum  then.cwt
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  *seed
                                  ==
  =/  [typ=@ta validated=(list resolved-scalar)]
    %:  check-consistent-types
      ?~  else.scalar  then-dos
      :-  %-  tail  %:  evaluate-datum  (need else.scalar)
                                        named-ctes
                                        qualifier-lookup
                                        map-meta
                                        resolved-scalars
                                        bowl
                                        *seed
                                        ==
          then-dos
      ~
      named-ctes
      map-meta
      resolved-scalars
      ==
  =/  fns-to-apply  %:  case-simple-fns  scalar
                                         named-ctes
                                         qualifier-lookup
                                         map-meta
                                         resolved-scalars
                                         bowl
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
          =resolved-scalars
          =bowl:gall
          ==
  ^-  (list [$-(data-row ?) resolved-scalar])
  =/  fns=(list [$-(data-row ?) resolved-scalar])
        %+  turn  cases.scalar
                  |=  cwt=case-when-then:ast
                  =/  qualified-pred
                        %+  normalize-predicate  ;;(predicate:ast when.cwt)
                                                 qualifier-lookup
                  :-  %:  prepare-predicate  qualified-pred
                                             map-meta
                                             qualifier-lookup
                                             named-ctes
                                             resolved-scalars
                                             ==
                      %-  tail
                      %:  evaluate-datum  then.cwt
                                         named-ctes
                                         qualifier-lookup
                                         map-meta
                                         resolved-scalars
                                         bowl
                                         *seed
                                         ==
  ?~  else.scalar  fns
  =/  else-rs=resolved-scalar
    %-  tail  %:  evaluate-datum  (need else.scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  *seed
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
          =resolved-scalars
          =bowl:gall
          ==
  ^-  (list [$-(data-row ?) resolved-scalar])
  =/  eq-pred
    |=  [target=* when=* =data-row]
    ^-  ?
    =/  target-ps
          %:  evaluate-datum  target
                              named-ctes
                              qualifier-lookup
                              map-meta
                              resolved-scalars
                              bowl
                              *seed
                              ==
    =/  target-val  %+  apply-scalar  data-row  +.target-ps
    =/  when-ps
          %:  evaluate-datum  when
                              named-ctes
                              qualifier-lookup
                              map-meta
                              resolved-scalars
                              bowl
                              *seed
                              ==
    =/  when-val  %+  apply-scalar  data-row  +.when-ps
    =(target-val when-val)
  =/  fns  %+  turn  cases.scalar
                     |=  cwt=case-when-then:ast
                     :-  ?:  ?=(ops-and-conjs:ast -.when.cwt)
                           |=  =data-row
                           =/  qualified-pred
                             %+  normalize-predicate  ;;(predicate:ast when.cwt)
                                                      qualifier-lookup
                           %-  %:  prepare-predicate  qualified-pred
                                                      map-meta
                                                      qualifier-lookup
                                                      named-ctes
                                                      resolved-scalars
                                                      ==
                               data-row
                         |=  =data-row
                          %^  eq-pred  (need target.scalar)
                                      ;;(scalar-node:ast when.cwt)
                                      data-row
                         ::
                         %-  tail
                         %:  evaluate-datum  then.cwt
                                            named-ctes
                                            qualifier-lookup
                                            map-meta
                                            resolved-scalars
                                            bowl
                                            *seed
                                            ==
  ?~  else.scalar  fns
  =/  else-rs=resolved-scalar
    %-  tail  %:  evaluate-datum  (need else.scalar)
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  *seed
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
          =resolved-scalars
          =bowl:gall
          ==
  ^-  resolved-scalar
  =/  [typ=@ta validated=(list resolved-scalar)]
    %:  check-consistent-types  %+  turn  data.scalar
                                          |=  item=*
                                          %-  tail
                                          %:  evaluate-datum  item
                                                             named-ctes
                                                             qualifier-lookup
                                                             map-meta
                                                             resolved-scalars
                                                             bowl
                                                             *seed
                                                             ==
                                  ~
                                  named-ctes
                                  map-meta
                                  resolved-scalars
                                  ==
  ::  first item is a concrete value: return it immediately as resolved-scalar
  ?~  validated  ~|("no non-null value found in row" !!)
  ?:  ?=(dime i.validated)  i.validated
  ::  otherwise build a %fn that walks validated at runtime per data-row,
  ::  returning the first non-null value; the list-walk is captured in the gate
  =/  fn
    |=  [datums=(list resolved-scalar) =data-row]
    :: to do: once outer joins implemented must test columns for existence
    ::        in data-row
    ^-  dime
    |-
    ?~  datums  ~|("coalesce: no non-null value found in row" !!)
    ?:  ?=(dime i.datums)  i.datums
    (f.i.datums data-row)
  [%fn typ |=(=data-row (fn validated data-row))]
::
++  prepare-arithmetic
  |=  $:
        scalar=arithmetic:ast
        =named-ctes
        =qualifier-lookup
        =map-meta
        =resolved-scalars
        =bowl:gall
      ==
  ^-  resolved-scalar
  =/  l=resolved-scalar
    %-  tail  %:  evaluate-datum  left.scalar
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  *seed
                                  ==
  =/  r=resolved-scalar
    %-  tail  %:  evaluate-datum  right.scalar
                                  named-ctes
                                  qualifier-lookup
                                  map-meta
                                  resolved-scalars
                                  bowl
                                  *seed
                                  ==
  =/  l-number-system  ?:  ?=(dime l)  -.l
                       type.l
  =/  r-number-system  ?:  ?=(dime r)  -.r
                       type.r
  ?.  ?|  =(l-number-system r-number-system)
          &(=(%ket operator.scalar) ?=(number-systems r-number-system))
          ==
    ~|  "number system conflict: ".
        "{<l-number-system>} {<operator.scalar>} {<r-number-system>}"
        !!
  ?.  ?=(number-systems l-number-system)
    ~|  "{<l-number-system>} {<operator.scalar>} {<r-number-system>} : ".
        "{<l-number-system>} not a supported number system, ".
        "need ?(~.rd ~.sd ~.ud)"
        !!
  =/  check-sub-underflow
    |=  [left=@ud right=@ud]
    ^-  ?
    (gth right left)
  =/  guard-div-zero-rd
    |=  val=@rd
    ^-  @rd
    ?:  =(val .~0)
      ~|("division by zero" !!)
    val
  =/  guard-div-zero-sd
    |=  val=@sd
    ^-  @sd
    ?:  =(val --0)
      ~|("division by zero" !!)
    val
  =/  guard-div-zero-ud
    |=  val=@ud
    ^-  @ud
    ?:  =(val 0)
      ~|("division by zero" !!)
    val
  =/  guard-sub-underflow-ud
    |=  [left=@ud right=@ud]
    ^-  [@ud @ud]
    ?:  (check-sub-underflow left right)
      ~|("subtraction underflow" !!)
    [left right]
  ?-  operator.scalar
      ::
      %lus
        ?:  &(?=(dime l) ?=(dime r))
          ?-  l-number-system
            ::
            %rd  [-.l (add:rd +.l +.r)]
            ::
            %sd  [-.l (sum:si +.l +.r)]
            ::
            %ud  [-.l (add +.l +.r)]
            ==
        :+  %fn
            l-number-system
            |=  =data-row
            ^-  dime
            ?-  l-number-system
              ::
              %rd
                ?:  ?=(dime l)
                  ?:  ?=(dime r)  ~|("eval-operator: can't get here" !!)
                  [l-number-system (add:rd +.l +:(f.r data-row))]
                ?:  ?=(dime r)
                  [l-number-system (add:rd +:(f.l data-row) +.r)]
                [l-number-system (add:rd +:(f.l data-row) +:(f.r data-row))]
              ::
              %sd
                ?:  ?=(dime l)
                  ?:  ?=(dime r)  ~|("eval-operator: can't get here" !!)
                  [l-number-system (sum:si +.l +:(f.r data-row))]
                ?:  ?=(dime r)
                  [l-number-system (sum:si +:(f.l data-row) +.r)]
                [l-number-system (sum:si +:(f.l data-row) +:(f.r data-row))]
              ::
              %ud
                ?:  ?=(dime l)
                  ?:  ?=(dime r)  ~|("eval-operator: can't get here" !!)
                  [l-number-system (add +.l +:(f.r data-row))]
                ?:  ?=(dime r)
                  [l-number-system (add +:(f.l data-row) +.r)]
                [l-number-system (add +:(f.l data-row) +:(f.r data-row))]
              ==
      ::
      %hep
          ?:  &(?=(dime l) ?=(dime r))
          ?-  l-number-system
            ::
            %rd  [-.l (sub:rd +.l +.r)]
            ::
            %sd  [-.l (dif:si +.l +.r)]
            ::
            %ud
              =/  args  (guard-sub-underflow-ud +.l +.r)
              [-.l (sub -.args +.args)]
            ==
        :+  %fn
            l-number-system
            |=  =data-row
            ^-  dime
            ?-  l-number-system
              ::
              %rd
                ?:  ?=(dime l)
                  ?:  ?=(dime r)  ~|("eval-operator: can't get here" !!)
                  [l-number-system (sub:rd +.l +:(f.r data-row))]
                ?:  ?=(dime r)
                  [l-number-system (sub:rd +:(f.l data-row) +.r)]
                [l-number-system (sub:rd +:(f.l data-row) +:(f.r data-row))]
              ::
              %sd
                ?:  ?=(dime l)
                  ?:  ?=(dime r)  ~|("eval-operator: can't get here" !!)
                  [l-number-system (dif:si +.l +:(f.r data-row))]
                ?:  ?=(dime r)
                  [l-number-system (dif:si +:(f.l data-row) +.r)]
                [l-number-system (dif:si +:(f.l data-row) +:(f.r data-row))]
              ::
              %ud
                ?:  ?=(dime l)
                  ?:  ?=(dime r)  ~|("eval-operator: can't get here" !!)
                  =/  args  (guard-sub-underflow-ud +.l +:(f.r data-row))
                  [l-number-system (sub -.args +.args)]
                ?:  ?=(dime r)
                  =/  args  (guard-sub-underflow-ud +:(f.l data-row) +.r)
                  [l-number-system (sub -.args +.args)]
                =/  args  (guard-sub-underflow-ud +:(f.l data-row) +:(f.r data-row))
                [l-number-system (sub -.args +.args)]
              ==
      ::
      %tar
         ?:  &(?=(dime l) ?=(dime r))
          ?-  l-number-system
            ::
            %rd  [-.l (mul:rd +.l +.r)]
            ::
            %sd  [-.l (pro:si +.l +.r)]
            ::
            %ud  [-.l (mul +.l +.r)]
            ==
        :+  %fn
            l-number-system
            |=  =data-row
            ^-  dime
            ?-  l-number-system
              ::
              %rd
                ?:  ?=(dime l)
                  ?:  ?=(dime r)  ~|("eval-operator: can't get here" !!)
                  [l-number-system (mul:rd +.l +:(f.r data-row))]
                ?:  ?=(dime r)
                  [l-number-system (mul:rd +:(f.l data-row) +.r)]
                [l-number-system (mul:rd +:(f.l data-row) +:(f.r data-row))]
              ::
              %sd
                ?:  ?=(dime l)
                  ?:  ?=(dime r)  ~|("eval-operator: can't get here" !!)
                  [l-number-system (pro:si +.l +:(f.r data-row))]
                ?:  ?=(dime r)
                  [l-number-system (pro:si +:(f.l data-row) +.r)]
                [l-number-system (pro:si +:(f.l data-row) +:(f.r data-row))]
              ::
              %ud
                ?:  ?=(dime l)
                  ?:  ?=(dime r)  ~|("eval-operator: can't get here" !!)
                  [l-number-system (mul +.l +:(f.r data-row))]
                ?:  ?=(dime r)
                  [l-number-system (mul +:(f.l data-row) +.r)]
                [l-number-system (mul +:(f.l data-row) +:(f.r data-row))]
              ==
      ::
      %fas
          ?:  &(?=(dime l) ?=(dime r))
          ?-  l-number-system
            ::
            %rd  [-.l (div:rd +.l (guard-div-zero-rd +.r))]
            ::
            %sd  [-.l (fra:si +.l (guard-div-zero-sd +.r))]
            ::
            %ud  [-.l (div +.l (guard-div-zero-ud +.r))]
            ==
        :+  %fn
            l-number-system
            |=  =data-row
            ^-  dime
            ?-  l-number-system
              ::
              %rd
                ?:  ?=(dime l)
                  ?:  ?=(dime r)  ~|("eval-operator: can't get here" !!)
                  [l-number-system (div:rd +.l (guard-div-zero-rd +:(f.r data-row)))]
                ?:  ?=(dime r)
                  [l-number-system (div:rd +:(f.l data-row) (guard-div-zero-rd +.r))]
                [l-number-system (div:rd +:(f.l data-row) (guard-div-zero-rd +:(f.r data-row)))]
              ::
              %sd
                ?:  ?=(dime l)
                  ?:  ?=(dime r)  ~|("eval-operator: can't get here" !!)
                  [l-number-system (fra:si +.l (guard-div-zero-sd +:(f.r data-row)))]
                ?:  ?=(dime r)
                  [l-number-system (fra:si +:(f.l data-row) (guard-div-zero-sd +.r))]
                [l-number-system (fra:si +:(f.l data-row) (guard-div-zero-sd +:(f.r data-row)))]
              ::
              %ud
                ?:  ?=(dime l)
                  ?:  ?=(dime r)  ~|("eval-operator: can't get here" !!)
                  [l-number-system (div +.l (guard-div-zero-ud +:(f.r data-row)))]
                ?:  ?=(dime r)
                  [l-number-system (div +:(f.l data-row) (guard-div-zero-ud +.r))]
                [l-number-system (div +:(f.l data-row) (guard-div-zero-ud +:(f.r data-row)))]
              ==
      ::
      %ket
          ?:  &(?=(dime l) ?=(dime r))
          =/  l-rd
            ?-  l-number-system
              %rd  +.l
              %ud  (sun:rd +.l)
              %sd  (san:rd `@s`+.l)
            ==
          =/  r-rd
            ?:  =(r-number-system %rd)  +.r
            ?:  =(r-number-system %ud)  (sun:rd +.r)
            (san:rd `@s`+.r)
          ?:  (lth:rd r-rd .~0)
            ~|("negative exponent {<r>} not supported" !!)
          =/  res-rd
            ?:  =(r-number-system %rd)
              (~(pow rd:math [%z .~1e-15]) l-rd r-rd)
            (~(pow-n rd:math [%z .~1e-15]) l-rd r-rd)
          ?-  l-number-system
            %rd  [l-number-system res-rd]
            %ud  [l-number-system (abs:si `@s`(need (toi:rd res-rd)))]
            %sd  [l-number-system (need (toi:rd res-rd))]
          ==
      :+  %fn
          l-number-system
          |=  =data-row
          ^-  dime
          =/  l-raw  ?:(?=(dime l) +.l +:(f.l data-row))
          =/  r-raw  ?:(?=(dime r) +.r +:(f.r data-row))
          =/  l-rd
            ?-  l-number-system
              %rd  l-raw
              %ud  (sun:rd l-raw)
              %sd  (san:rd `@s`l-raw)
            ==
          =/  r-rd
            ?:  =(r-number-system %rd)  r-raw
            ?:  =(r-number-system %ud)  (sun:rd r-raw)
            (san:rd `@s`r-raw)
          ?:  (lth:rd r-rd .~0)
            ~|("negative exponent {<r>} not supported" !!)
          =/  res-rd
            ?:  =(r-number-system %rd)
              (~(pow rd:math [%z .~1e-15]) l-rd r-rd)
            (~(pow-n rd:math [%z .~1e-15]) l-rd r-rd)
          ?-  l-number-system
            %rd  [l-number-system res-rd]
            %ud  [l-number-system (abs:si `@s`(need (toi:rd res-rd)))]
            %sd  [l-number-system (need (toi:rd res-rd))]
          ==
      ::
      %cen
          ?:  &(?=(dime l) ?=(dime r))
          ?-  l-number-system
            ::
            %rd  ~|("remainder not implemented for @rd" !!)
            ::
            %sd  [-.l (rem:si +.l +.r)]
            ::
            %ud  [-.l (mod +.l +.r)]
            ==
        :+  %fn
            l-number-system
            |=  =data-row
            ^-  dime
            ?-  l-number-system
              ::
              %rd
                ~|("remainder not implemented for @rd" !!)
              ::
              %sd
                ?:  ?=(dime l)
                  ?:  ?=(dime r)  ~|("eval-operator: can't get here" !!)
                  [l-number-system (rem:si +.l +:(f.r data-row))]
                ?:  ?=(dime r)
                  [l-number-system (rem:si +:(f.l data-row) +.r)]
                [l-number-system (rem:si +:(f.l data-row) +:(f.r data-row))]
              ::
              %ud
                ?:  ?=(dime l)
                  ?:  ?=(dime r)  ~|("eval-operator: can't get here" !!)
                  [l-number-system (mod +.l +:(f.r data-row))]
                ?:  ?=(dime r)
                  [l-number-system (mod +:(f.l data-row) +.r)]
                [l-number-system (mod +:(f.l data-row) +:(f.r data-row))]
              ==
    ==
::
++  check-consistent-types
  ::  validate that all datum items share a common aura type,
  ::  and (if allowed is non-empty) that type is in the allowed list.
  ::  returns [common-type list].
  ::  crashes on empty dos.
  |=  $:  dos=(list resolved-scalar)
          allowed=(list @ta)
          =named-ctes
          =map-meta
          =resolved-scalars          
          ==
  ^-  [@ta (list resolved-scalar)]
  ::  resolve type and possibly substitute item; returns [type resolved-item]
  =/  resolve-item  |=  item=resolved-scalar
                    ^-  [@ta resolved-scalar]
                    ?:  ?=(dime item)
                      [-.item item]
                    [type.item item]
  ::  walk the list, tracking expected type, verifying consistency,
  ::  and accumulating the (possibly-substituted) output list
  =/  expected  *(unit @ta)
  =/  out       *(list resolved-scalar)
  =/  items  dos
  |-  ^-  [@ta (list resolved-scalar)]
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
  =/  [t=@ta sub=resolved-scalar]  (resolve-item i.items)
  ?~  expected
    $(expected `t, out [sub out], items t.items)
  ~|  "check-consistent-types: inconsistent types, expected {<u.expected>} ".
      "but got {<t>} at {<i.items>}"
  ?>  =(u.expected t)
  $(out [sub out], items t.items)
::
++  got-qualified-col-type
  |=  [=map-meta col=qualified-column:ast]
  ^-  @ta
  =/  normalized-col=qualified-column:ast
    col(qualifier (normalize-qt-alias qualifier.col))

  ?:  =(%qualified-map-meta -.map-meta)
    -:(~(got bi:mip +:;;(qualified-map-meta map-meta)) qualifier.normalized-col name.normalized-col)
  -:(~(got by +:;;(unqualified-map-meta map-meta)) name.normalized-col)
::
++  got-column-dime
  |=  [=map-meta col=qualified-column:ast =data-row] 
  ^-  dime
  =/  normalized-col=qualified-column:ast
    col(qualifier (normalize-qt-alias qualifier.col))
  ~|  "got-column-dime: failed for {<normalized-col>}"
  ?-  -.data-row
      %joined-row
        :-  (got-qualified-col-type map-meta normalized-col)
            (~(got bi:mip data.data-row) qualifier.normalized-col name.normalized-col)
      ::
      %indexed-row
        :-  (got-qualified-col-type map-meta normalized-col)
            (~(got by data.data-row) name.normalized-col)
      ==
::
++  evaluate-datum
  |=  $:  datum=*
          =named-ctes
          =qualifier-lookup
          =map-meta
          =resolved-scalars
          =bowl:gall
          =seed
          ==
  ^-  [@uvJ resolved-scalar]
  ~|  "evaluate-datum: failed {<datum>}"
  ?:  ?=(scalar-name:ast datum)    :: must be before dime
    :-  seed
    ~|  "scalar {<name.datum>} not found"
        (~(got by resolved-scalars) name.datum)
  ?:  ?=(dime datum)
    [seed datum]
  ?:  ?=(cte-column:ast datum)
    [seed (resolve-cte-column datum named-ctes)]
  ?:  ?=(qualified-column:ast datum)
    :-  seed
    :+  %fn
        %+  got-qualified-col-type  map-meta
                                    ;;(qualified-column:ast datum)
        |=  =data-row
          %^  got-column-dime  map-meta
                              ;;(qualified-column:ast datum)
                              data-row
  ?:  ?=(unqualified-column:ast datum)
    =/  table-list
          (~(got by qualifier-lookup) name:;;(unqualified-column:ast datum))
    ?~  table-list  ~|("no table!" !!)
    ?:  (gth (lent table-list) 1)  ~|("too many tables!" !!)
    =/  column=qualified-column:ast
      [%qualified-column -.table-list name:;;(unqualified-column:ast datum) ~]
    :-  seed
    :+  %fn
        (got-qualified-col-type map-meta column)
        |=  =data-row
            (got-column-dime map-meta column data-row)
  %:  prepare-scalar  ;;(scalar-function:ast datum)
                      named-ctes
                      qualifier-lookup
                      map-meta
                      resolved-scalars
                      bowl
                      seed
                      ==
--
