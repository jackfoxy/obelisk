:: abstract syntax trees for urQL parsing and execution
::
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
::  generic urQL command
::
+$  command
  $+  command
  $%
    alter-index
    alter-namespace
    alter-table
    create-database
    create-index
    create-namespace
    create-table
    create-view
    delete
    drop-database
    drop-index
    drop-namespace
    drop-table
    drop-view
    grant
    revoke
    selection
    truncate-table
    update
  ==
::
::  simple union types
::
+$  referential-integrity-action   ?(%delete-cascade %update-cascade)
+$  index-action         ?(%rebuild %disable %resume)
+$  all-or-any           ?(%all %any)
+$  bool-conjunction     ?(%and %or)
+$  object-type          ?(%table %view)
+$  join-type
  ?(%join %left-join %right-join %outer-join %cross-join)
::
::  command component types
::
+$  value-literals
  $:
    %value-literals
    dime               :: false dime [<aura of type> <crip of literal list>]
  ==
+$  ordered-column
  $:
    %ordered-column
    name=@tas
    ascending=?
  ==
+$  column
  $:
    %column
    name=@tas
    type=@ta
  ==
+$  qualified-table
  $+  qualified-table
  $:
    %qualified-table
    ship=(unit @p)
    database=@tas
    namespace=@tas
    name=@tas
    alias=(unit @t)
  ==
+$  qualified-column
  $+  qualified-column
  $:
    %qualified-column
    qualifier=qualified-table
    name=@tas
    alias=(unit @t)
  ==
+$  foreign-key
  $:
    %foreign-key
    name=@tas
    =qualified-table
    columns=(list ordered-column)                    :: the source columns
    reference-table=qualified-table                 :: reference (target) table
    reference-columns=(list @t)                      :: and columns
                  :: what to do when referenced item deletes or updates
    referential-integrity=(list referential-integrity-action)
  ==
::
::  expressions
::
:: { = | <> | != | > | >= | !> | < | <= | !< | BETWEEN...AND...
::       | IS DISTINCT FROM | IS NOT DISTINCT FROM }
+$  ternary-op     ?(%between %not-between)
+$  inequality-op  ?(%neq %gt %gte %lt %lte)
+$  all-any-op     ?(%all %any)
+$  binary-op      ?(%eq inequality-op %equiv %not-equiv %in %not-in)
+$  unary-op       ?(%exists %not-exists %not)
+$  conjunction    ?(%and %or)
+$  ops-and-conjs  ?(ternary-op binary-op unary-op all-any-op conjunction)
+$  predicate-component
      $?  ops-and-conjs
          qualified-column
          unqualified-column
          dime
          value-literals
          cte-alias
          scalar-alias
          aggregate
          ==
+$  predicate     (tree predicate-component)
+$  datum         $%(qualified-column unqualified-column dime)
+$  scalar-op     ?(%lus %tar %hep %fas %ket)
+$  scalar-token  ?(%pal %par scalar-op)
+$  arithmetic
  $:
    %arithmetic
    operator=scalar-op
    left=datum-or-scalar
    right=datum-or-scalar
  ==
+$  if-then-else
  $:
    %if-then-else
    if=predicate                         :: predicate | datum
    then=datum-or-scalar
    else=datum-or-scalar
  ==
+$  case-when-then
  $:
    %case-when-then
    when=predicate                       :: predicate | datum
    then=datum-or-scalar
  ==
+$  case
  $:
    %case
    target=datum-or-scalar
    cases=(list case-when-then)
    else=(unit datum-or-scalar)
  ==
+$  coalesce
  $+  coalesce
  $:
    %coalesce
    data=(list datum-or-scalar)
  ==
::
::  datetime functions
::
+$  getdate                 [%getdate]
+$  sysdatetimeoffset       [%sysdatetimeoffset]
+$  day                     [%day date=literal-value]
+$  month                   [%month date=literal-value]
+$  year                    [%year date=literal-value]
::
::  mathematical functions
::
+$  abs        [%abs numeric-expression=literal-value]
+$  log        [%log float-expression=literal-value base=(unit literal-value)]
+$  floor      [%floor numeric-expression=literal-value]
+$  power      [%power float-expression=literal-value exponent=literal-value]
+$  ceiling    [%ceiling numeric-expression=literal-value]
+$  round      
  $:  %round
    numeric-expression=literal-value
    length=literal-value
    function=(unit literal-value)
  ==
+$  sign       [%sign numeric-expression=literal-value]
+$  sqrt       [%sqrt float-expression=literal-value]
::
::  string functions
::
+$  len        [%len string-expression=literal-value]
+$  left       
  [%left character-expression=literal-value integer-expression=literal-value]
+$  right      
  [%right character-expression=literal-value integer-expression=literal-value]
+$  substring  
  $:  %substring
    string-expression=literal-value
    start=literal-value
    length=literal-value
  ==
+$  trim       [%trim characters=(unit literal-value) string=literal-value]
+$  concat     [%concat argument1=literal-value argument2=literal-value]
::
+$  scalar-function
  $%
    if-then-else
    case
    coalesce
    :: arithmetic
    scalar-alias
    :: builtin functions
    getdate
    sysdatetimeoffset
    day
    month
    year
    abs
    log
    floor
    power
    ceiling
    round
    sign
    sqrt
    len
    left
    right
    substring
    trim
    concat
  ==
+$  literal-value  $:(%literal-value dime=dime)
+$  cte-alias      $:(%cte-alias alias=@t)
+$  scalar-alias   $:(%scalar-alias alias=@t)
++  datum-or-scalar  
  $%
    qualified-column
    unqualified-column
    literal-value
    cte-alias
    scalar-function
  ==
::
::  query
::
::  $query:
+$  query
  $:
    %query
    from=(unit from)
    scalars=(list scalar)
    =predicate
    group-by=(list grouping-column)
    having=predicate
    =select
    order-by=(list ordering-column)
  ==
::
::  $from:
+$  from
  $:
    %from
    object=relation
    as-of=(unit as-of)
    joins=(list joined-object)
  ==
+$  joined-object
  $:
    %joined-object
    join=join-type
    object=relation
    as-of=(unit as-of)
    =predicate
  ==
::
::  $relation:
+$  relation
  $:
    %relation
    object=$%(qualified-table cte-alias query-row)
  ==
::
+$  query-row     ::  parses, not used for now, may never be used
  $:
    %query-row
    alias=(unit @t)
    (list @t)
  ==
::
::  $select:
+$  select
  $:
    %select
    top=(unit @ud)
    columns=(list selected-column)
  ==
+$  selected-column
  $%
    qualified-column
    unqualified-column
    qualified-table
    selected-aggregate
    selected-value
    selected-all
    selected-all-object
  ==
+$  unqualified-column
  $:
    %unqualified-column
    name=@tas
    alias=(unit @t)
    ==
+$  selected-all
  $:
    %all
    %all
  ==

+$  selected-all-object  [%all-object qualified-table]

+$  selected-aggregate
  $:
    %selected-aggregate
    aggregate=aggregate
    alias=(unit @t)
  ==
+$  scalar
  $:
    %scalar
    scalar=scalar-function
    alias=@t
  ==
+$  selected-value
  $:
    %selected-value
    value=dime
    alias=(unit @t)
  ==
+$  aggregate
  $:
  %aggregate
  function=@t
  source=aggregate-source
  ==
+$  aggregate-source     $%(qualified-column) :: selected-scalar)
+$  grouping-column      ?(qualified-column @ud)
+$  ordering-column
  $:
  %ordering-column
  column=grouping-column
  ascending=?
  ==
+$  with
  $:
    %with
    (list cte)
  ==
::
::  $selection:
+$  selection
  $:
  %selection
  ctes=(list cte)
  set-functions=(tree set-function)
  ==
::
::  $cte:
+$  cte
  $:
    %cte
    name=@tas
    =query
  ==
+$  set-op
  $?
    %union
    %except
    %intersect
    %divided-by
    %divide-with-remainder
    %into
  ==
+$  set-cmd       $%(insert merge query)
+$  set-function  ?(set-op set-cmd)
::
::  data manipulation ASTs
::
::
::  $delete:
+$  delete
  $:
    %delete
    ctes=(list cte)
    table=qualified-table
    as-of=(unit as-of)
    =predicate
  ==
::
::  $update:
+$  update
  $:
    %update
    ctes=(list cte)
    table=qualified-table
    as-of=(unit as-of)
    $:  columns=(list qualified-column)
        values=(list value-or-default)
        ==
    =predicate
  ==
::
::
+$  insert-values      $%([%data (list (list value-or-default))] [%query query])
::
::  $insert:
+$  insert
  $:
    %insert
    table=qualified-table
    as-of=(unit as-of)
    columns=(unit (list @tas))
    values=insert-values
  ==
+$  value-or-default     ?(%default datum)
::
::  $merge: merge from source relation into target relation
+$  merge
  $:
    %merge
    target-table=relation
    new-table=(unit relation)
    source-table=relation
    =predicate
    matched=(list matching)
    unmatched-by-target=(list matching)
    unmatched-by-source=(list matching)
    as-of=(unit as-of)
  ==
+$  matching
  $:
    %matching
    =predicate
    matching-profile=matching-profile
  ==
+$  matching-action  ?(%insert %update %delete)
+$  matching-profile
  $%([%insert (list [@t datum])] [%update (list [@t datum])] %delete)
+$  matching-lists
  $:  matched=(list matching)
    not-target=(list matching)
    not-source=(list matching)
  ==
::
::  $truncate-table:
+$  truncate-table
  $:
    %truncate-table
    table=qualified-table
    as-of=(unit as-of)
  ==
::
::  create ASTs
::
+$  as-of-offset
  $:
    %as-of-offset
    offset=@ud
    units=?(%seconds %minutes %hours %days %weeks %months %years)
  ==
+$  as-of  ?([%da @da] [%dr @dr] as-of-offset)
::
::  $create-database: $:([%create-database name=@tas])
+$  create-database      $:([%create-database name=@tas as-of=(unit as-of)])
::
::  $create-index:
+$  create-index
  $:
    %create-index
    name=@tas
    =qualified-table
    unique=?
    columns=(list ordered-column)
    as-of=(unit as-of)
  ==
::
::  $create-namespace
+$  create-namespace
  $:  %create-namespace
    database-name=@tas
    name=@tas
    as-of=(unit as-of)
  ==
::
::  $create-table
+$  create-table
  $:  %create-table
    table=qualified-table
    columns=(list column)
    pri-indx=(list ordered-column)
    foreign-keys=(list foreign-key)
    as-of=(unit as-of)
  ==
::
::  $create-trigger: TBD
+$  create-trigger
  $:
    %create-trigger
    name=@tas
    =qualified-table
    enabled=?
  ==
::
::  $create-type: TBD
+$  create-type          $:([%create-type name=@tas])
::
::  $create-view: persist a selection as a view
+$  create-view
  $:
    %create-view
    view=qualified-table
    selection
  ==
::
::  drop ASTs
::
::  $drop-database: name=@tas force=?
+$  drop-database        $:([%drop-database name=@tas force=?])
::
::  $drop-index: name=@tas object=qualified-table
+$  drop-index
  $:
    %drop-index
    name=@tas
    =qualified-table
    as-of=(unit as-of)
  ==
::
::  $drop-namespace: database-name=@tas name=@tas force=?
+$  drop-namespace
  $:([%drop-namespace database-name=@tas name=@tas force=? as-of=(unit as-of)])
::
::  $drop-table: table=qualified-table force=?
+$  drop-table
  $:  %drop-table
    table=qualified-table
    force=?
    as-of=(unit as-of)
  ==
::
::  $drop-trigger: TBD
+$  drop-trigger
  $:
    %drop-trigger
    name=@tas
    =qualified-table
  ==
::
::  $drop-type: TBD
+$  drop-type            $:([%drop-type name=@tas])
::
::  $drop-view: view=qualified-table force=?
+$  drop-view
  $:
    %drop-view
    view=qualified-table
    force=?
  ==
::
::  alter ASTs
::
::
::  $alter-index: change an index
+$  alter-index
  $:
    %alter-index
    name=qualified-table
    object=qualified-table
    columns=(list ordered-column)
    action=index-action
    as-of=(unit as-of)
  ==
::
::  $alter-namespace: move an object from one namespace to another
+$  alter-namespace
  $:  %alter-namespace
    database-name=@tas
    source-namespace=@tas
    object-type=object-type
    target-namespace=@tas
    target-name=@tas
    as-of=(unit as-of)
  ==
::
::  $alter-table: to do - this could be simpler
+$  alter-table
  $:
    %alter-table
    table=qualified-table
    alter-columns=(list column)
    add-columns=(list column)
    drop-columns=(list @tas)
    add-foreign-keys=(list foreign-key)
    drop-foreign-keys=(list @tas)
    as-of=(unit as-of)
  ==
::
::  $alter-trigger: TBD
+$  alter-trigger
  $:
    %alter-trigger
    name=@tas
    =qualified-table
    enabled=?
  ==
::
::  $alter-view: view=qualified-table selection
+$  alter-view
  $:
    %alter-view
    view=qualified-table
    =selection
  ==
::
::  permissions
::
::
::  $grant-permission:  ?(%adminread %readonly %readwrite)
+$  grant-permission     ?(%adminread %readonly %readwrite)
::
::  $grantee: ?(%parent %siblings %moons %our @p)
::            $dime
+$  grantee  
  $?  [@ta %parent]
      [@ta %siblings]
      [@ta %moons]
      [@ta %our]
      [@ta @p]
      ==
::
::  $revoke-from: ?(%parent %siblings %moons %all)
+$  revoke-from          ?(%parent %siblings %moons %all)
::
::  $grant-object: ?(%server %database %namespace %table %table-column)
+$  grant-object  
  $%  [%server %server]
      [%database @tas]
      [%namespace [@tas @tas]]
      [%table qualified-table]
      [%table-column path]
      ==
::
::  $sec-time:  pair  ?([%da @da] [%dr @dr])
::                    (unit ?([%da @da] [%dr @dr]))
::
::  valid states:  [p=[%dr @dr] q=~]
::                   duration is timespan
::                 [p=[%dr @dr] q=[~ [%da @da]]]
::                   duration is timespan beginning at time
::                 [p=[%da @da] q=[~ [%da @da]]]
::                   duration begins at time and ends at time
::
+$  sec-time  (pair ?([%da @da] [%dr @dr]) (unit [%da @da]))
::
::  $grant:  permission=grant-permission
::           grantees=(list [grantee (unit path)])
::           grant-objects=(list grant-object)
::           duration=(unit sec-time)
+$  grant
  $:
    %grant
    permission=grant-permission
    grantees=(list [dime (unit path)])
    grant-objects=(list grant-object)
    duration=(unit sec-time)
  ==
::
::  $revoke-permission: ?(%adminread %readonly %readwrite %all)
+$  revoke-permission    ?(%adminread %readonly %readwrite %all)
::
::  $revoke-object: ?([%database @t] [%namespace [@t @t]] %all qualified-table)
+$  revoke-object
  $%  [%all %all]
      [%server %server]
      [%database @tas]
      [%namespace [@tas @tas]]
      [%table qualified-table]
      [%table-column path]
      ==
::ela
::  $revoke:  permission=revoke-permission from=revoke-from 
::            revoke-target=revoke-object
+$  revoke
  $:
    %revoke
    permission=revoke-permission
    from=(list [dime (unit path)])
    revoke-target=(list revoke-object)
    duration=(unit sec-time)
  ==
::
::  $security-group
+$  security-group 
  $:  %security-group
      grantees=(list [dime (unit path)])
      ==
::
::  $security-target
+$  security-target
  $:  %security-target
      grant-objects=(list grant-object)
      ==
--
