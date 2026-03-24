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
+$  referential-integrity-action  ?(%delete-cascade %update-cascade)
+$  index-action                  ?(%rebuild %disable %resume)
+$  all-or-any                    ?(%all %any)
+$  bool-conjunction              ?(%and %or)
+$  object-type                   ?(%table %view)
+$  join-type
  ?(%join %left-join %right-join %outer-join %cross-join)
::
::  command component types
::
+$  value-literals
  $:  %value-literals
    dime               :: false dime [<aura of type> <crip of literal list>]
    ==
+$  ordered-column
  $:  %ordered-column
    name=@tas
    ascending=?
    ==
+$  column
  $:  %column
    name=@tas
    type=@ta
    addr=@
    ==
+$  qualified-table
  $+  qualified-table
  $:  %qualified-table
    ship=(unit @p)
    database=@tas
    namespace=@tas
    name=@tas
    alias=(unit @t)
    ==
+$  qualified-column
  $+  qualified-column
  $:  %qualified-column
    qualifier=qualified-table
    name=@tas
    alias=(unit @t)
    ==
+$  foreign-key
  $:  %foreign-key
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
  $?
    ops-and-conjs
    datum
    value-literals
    aggregate
    ==
+$  predicate     (tree predicate-component)
+$  datum 
  $%
    qualified-column
    unqualified-column
    cte-column
    cte-name
    scalar-name
    dime
    ==
::
+$  cte-name      $:(%cte-name name=@tas)
+$  cte-column    $:(%cte-column cte=@tas name=@tas)
::
::  query
::
::  $query:
+$  query
  $:  %query
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
  $:  %from
    =relation
    as-of=(unit as-of)
    joins=(list joined-relation)
    ==
+$  joined-relation
  $:  %joined-relation
    join=join-type
    =relation
    as-of=(unit as-of)
    =predicate
    ==
::
::  $relation:
+$  relation  $%(qualified-table cte-name query-row)
::
+$  query-row     ::  parses, not used for now, may never be used
  $:  %query-row
    alias=(unit @t)
    (list @t)
    ==
::
::  $select:
+$  select
  $:  %select
    top=(unit @ud)
    columns=(list selected-column)
    ==
+$  selected-column
  $%
    qualified-column
    unqualified-column
    cte-column
    selected-aggregate
    selected-value
    selected-all
    selected-all-table
    ==
+$  unqualified-column
  $:  %unqualified-column
    name=@tas
    alias=(unit @t)
    ==
+$  selected-all
  $:  %all  %all
    ==
+$  selected-all-table  $:([%all-object =qualified-table])
+$  selected-aggregate
  $:  %selected-aggregate
    aggregate=aggregate
    alias=(unit @t)
    ==
+$  selected-value
  $:  %selected-value
    value=dime
    alias=(unit @t)
    ==
+$  aggregate
  $:  %aggregate
    function=@t
    source=aggregate-source
    ==
+$  aggregate-source     $%(qualified-column unqualified-column)
+$  grouping-column      ?(qualified-column unqualified-column @ud)
+$  ordering-column
  $:  %ordering-column
    column=grouping-column
    ascending=?
    ==
+$  with
  $:  %with
    (list cte)
    ==
::
::  $selection:
+$  selection
  $:  %selection
    ctes=(list cte)
    set-functions=(tree set-function)
    ==
::
::  $cte:
+$  cte
  $:  %cte
    name=@tas
    =query
    ==
+$  set-op
    $?  %union  %except  %intersect  %divided-by  %divide-with-remainder  %into
    ==
+$  set-cmd       $%(insert merge query)
+$  set-function  ?(set-op set-cmd)
::
::  data manipulation ASTs
::
::
::  $delete:
+$  delete
  $:  %delete
    ctes=(list cte)
    table=qualified-table
    as-of=(unit as-of)
    =predicate
    ==
::
::  $update:
+$  update
  $:  %update
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
  $:  %insert
    table=qualified-table
    as-of=(unit as-of)
    columns=(unit (list @tas))
    values=insert-values
    ==
+$  value-or-default     ?(%default datum)
::
::  $merge: merge from source relation into target relation
+$  merge
  $:  %merge
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
  $:  %matching
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
  $:  %truncate-table
    table=qualified-table
    as-of=(unit as-of)
    ==
::
::  create ASTs
::
+$  as-of-offset
  $:  %as-of-offset
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
  $:  %create-index
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
  $:  %create-trigger
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
  $:  %create-view
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
  $:  %drop-index
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
  $:  %drop-trigger
    name=@tas
    =qualified-table
    ==
::
::  $drop-type: TBD
+$  drop-type            $:([%drop-type name=@tas])
::
::  $drop-view: view=qualified-table force=?
+$  drop-view
  $:  %drop-view
    view=qualified-table
    force=?
    ==
::
::  alter ASTs
::
::
::  $alter-index: change an index
+$  alter-index
  $:  %alter-index
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
  $:  %alter-table
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
  $:  %alter-trigger
    name=@tas
    =qualified-table
    enabled=?
    ==
::
::  $alter-view: view=qualified-table selection
+$  alter-view
  $:  %alter-view
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
  $?
    [@ta %parent]
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
  $%
    [%server %server]
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
  $:  %grant
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
  $%
    [%all %all]
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
  $:  %revoke
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
::
::  SCALARS
::
+$  scalar
  $:  %scalar
    name=@tas
    f=scalar-function
    ==
::
+$  scalar-function
  $%
    arithmetic
    case
    coalesce
    if-then-else
    :: datetime functions
    add-time
    day
    getutcdate
    hour
    minute
    month
    second
    subtract-time
    year
    :: math functions
    abs
    acos
    asin
    atan
    atan2
    ceiling
    cos
    degrees
    e
    floor
    log
    max
    min
    phi
    pi
    rand
    round
    sign
    sin
    sqrt
    tan
    tau
    ::  string functions
    concat
    left
    len
    right
    substring
    trim
    ==
::
+$  scalar-name
  $:  %scalar-name
      name=@tas
      ==
::
+$  scalar-node  $%  scalar-function
                     datum
                     ==
::
+$  arithmetic
  $:  %arithmetic
    operator=arithmetic-op
    left=scalar-node
    right=scalar-node
    ==
::
+$  arithmetic-op     ?(%lus %tar %hep %fas %cen %ket)
+$  arithmetic-token  ?(%pal %par arithmetic-op)
+$  number-systems    ?(%rd %sd %ud)
+$  time-element      ?(%da %dr)
::
+$  if-then-else
  $:  %if-then-else
    if=predicate
    then=scalar-node
    else=scalar-node
    ==
::
+$  case-when-then
  $:  %case-when-then
    when=$%(predicate scalar-node)
    then=scalar-node
    ==
::
+$  case
  $:  %case
    target=(unit scalar-node)
    cases=(list case-when-then)
    else=(unit scalar-node)
    ==
::
+$  coalesce
  $+  coalesce
  $:  %coalesce
    data=(list scalar-node)
    ==
::
::  datetime functions
::
+$  getutcdate
  $:  %getutcdate
    ~
  ==
::
+$  year
  $:  %year
    date=datum
  ==
::
+$  month
  $:  %month
    date=datum
  ==
::
+$  day
  $:  %day
    time-expression=datum
  ==
::
+$  hour
  $:  %hour
    time-expression=datum
  ==
::
+$  minute
  $:  %minute
    time-expression=datum
  ==
::
+$  second
  $:  %second
    time-expression=datum
  ==
+$  add-time
  $:  %add-time
    time-expression=datum
    duration=datum
  ==
+$  subtract-time
  $:  %subtract-time
    time-expression=datum
    duration=datum
  ==
::
::  mathematical functions
::
+$  abs
  $:  %abs
    numeric-expression=datum
  ==
::
+$  acos
  $:  %acos
    numeric-expression=datum
  ==
::
+$  asin
  $:  %asin
    numeric-expression=datum
  ==
::
+$  atan
  $:  %atan
    numeric-expression=datum
  ==
::
+$  atan2
  $:  %atan2
    numeric-expression-1=datum
    numeric-expression-2=datum
  ==
::
+$  ceiling
  $:  %ceiling
    numeric-expression=datum
  ==
::
+$  cos
  $:  %cos
    numeric-expression=datum
  ==
::
+$  degrees
  $:  %degrees
    numeric-expression=datum
  ==
::
+$  e
  $:  %e
    ~
  ==
::
+$  floor
  $:  %floor
    numeric-expression=datum
  ==
::
+$  log
  $:  %log
    float-expression=datum
    base=(unit datum)
  ==
::
+$  max
  $:  %max
    numeric-expression-1=datum
    numeric-expression-2=datum
  ==
::
+$  min
  $:  %min
    numeric-expression-1=datum
    numeric-expression-2=datum
  ==
::
+$  phi
  $:  %phi
    ~
  ==
::
+$  pi
  $:  %pi
    ~
  ==
::
+$  rand
  $:  %rand
    numeric-expression-1=datum
    numeric-expression-2=datum
  ==
::
+$  round
  $:  %round
    numeric-expression=datum
    length=datum
    ==
::
+$  sign
  $:  %sign
    numeric-expression=datum
  ==
::
+$  sin
  $:  %sin
    numeric-expression=datum
  ==
::
+$  sqrt
  $:  %sqrt
    float-expression=datum
  ==
::
+$  tan
  $:  %tan
    numeric-expression=datum
  ==
::
+$  tau
  $:  %tau
    ~
  ==
::
::  string functions
::
+$  concat
  $+  concat
  :: if we remove this bucpat the type checker loops infinitely
  :: scalar-function -> concat -> datum -> scalar-function
  $:  %concat
    args=$@(~ (list datum))
  ==
::
+$  left
  $:  %left
    character-expression=datum
    integer-expression=datum
  ==
::
+$  len
  $:  %len
    string-expression=datum
  ==
::
+$  right
  $:  %right
    character-expression=datum
    integer-expression=datum
  ==
::
+$  substring
  $:  %substring
    string-expression=datum
    start=datum
    length=datum
    ==
::
+$  trim
  $:  %trim
    characters=(unit datum)
    string=datum
  ==
--
