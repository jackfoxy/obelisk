# SCALAR FUNCTIONS


The full syntax involves complex manipulations at the row level through scalar functions, data aggregation across preliminary rows via aggregate functions, filtering by aggregation, and row ordering.

NOTE: scalar and aggregate functions are currently under development and not available. Also, these are subject to change.



```
<scalar-function> ::=
  IF <predicate> THEN { <expression> | <scalar-function> | <named-scalar> }
                 ELSE { <expression> | <scalar-function> | <named-scalar> } ENDIF
  | CASE <expression>
    WHEN { <expression> | <predicate> }
	  THEN { <expression> | <scalar-function> | <named-scalar> }
    [ [ ELSE { <expression> | <scalar-function> | <named-scalar> } ] [ ...n ] ]
    END
  | COALESCE ( <expression> [ ,...n ] )
  | <arithmetic>
  | <bitwise>
  | <predicate>
  | <boolean>
  | <loobean>
  | <scalar>
```
If a `CASE` expression uses `<predicate>`, the expected boolean (or loobean) logic applies. If it uses `<expression>` `@`0 is treated as false and any other value as true (not loobean). (NOTE: This is preliminary design subject to change.)

`COALESCE` returns the first `<expression>` in the list that exists. Non-existence occurs when a selected `<expression>` value is not returned due to an outer join not matching or `<scalar-query>` not returning rows.

