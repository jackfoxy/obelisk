::  abstract syntax trees for urQL parsing and execution
::
::  FOR DEVELOPERS
::  --------------
::
::  Include this file in your projects consuming %obelisk.
::
::  Minimally you will need the molds in the OUTPUT section.
::
::  You are strongly encouraged to use native urQL for all your interactions
::  with %obelisk. If you choose to write programs using the API in order to
::  skip the parse step it is unlikely your efforts will be significantly more
::  efficient.
::
::  If you do choose to interact via the command API ust the %commands poke.
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
    drop-database
    drop-index
    drop-namespace
    drop-table
    drop-view
    grant
    revoke
    crud-txn
    truncate-table
    ==
::
::  simple union types
::
+$  referential-integrity-action  ?(%delete-cascade %update-cascade)
+$  index-action                  ?(%rebuild %disable %resume)
+$  all-or-any                    ?(%all %any)
+$  bool-conjunction              ?(%and %or)
+$  table-or-view                 ?(%table %view)
+$  join-type
  ?(%join %left-join %right-join %outer-join %cross-join)
::
::  command component types
::
+$  value-literals
  $+  value-literals
  $:  %value-literals
    dime               :: false dime [<aura of type> <crip of literal list>]
    ==
+$  ordered-column
  $+  ordered-column
  $:  %ordered-column
    name=@tas
    ascending=?
    ==
+$  column
  $+  column
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
  $+  foreign-key
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
    scalar-name
    dime
    ==
::
+$  cte-name
  $+  cte-name
  $:  %cte-name
    name=@tas
    alias=(unit @t)
    ==
+$  cte-column
  $+  cte-column
  $:  %cte-column
    cte=@tas
    name=@tas
    ==
::
::  query
::
::  $query:
+$  query
  $+  query
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
  $+  from
  $:  %from
    =relation
    as-of=(unit as-of)
    joins=(list joined-relation)
    ==
+$  joined-relation
  $+  joined-relation
  $:  %joined-relation
    =join-type
    =relation
    as-of=(unit as-of)
    =predicate
    ==
::
::  $relation:
+$  relation  $%(qualified-table cte-name query-row)
::
+$  query-row     ::  parses, not used for now, may never be used
  $+  query-row
  $:  %query-row
    alias=(unit @t)
    (list @t)
    ==
::
::  $select:
+$  select
  $+  select
  $:  %select
    top=(unit @ud)
    columns=(list selected-column)
    ==
+$  selected-cte-column
  $+  selected-cte-column
  $:  %selected-cte-column
    cte=@tas
    name=@tas
    alias=(unit @t)
    ==
+$  selected-column
  $%
    qualified-column
    unqualified-column
    selected-scalar
    selected-cte-column
    selected-aggregate
    selected-value
    selected-all
    selected-all-table
    ==
+$  selected-scalar
  $+  selected-scalar
  $:  %selected-scalar
    name=@tas
    alias=(unit @t)
    ==
+$  unqualified-column
  $+  unqualified-column
  $:  %unqualified-column
    name=@tas
    alias=(unit @t)
    ==
+$  selected-all
  $+  selected-all
  $:  %all  %all
    ==
+$  selected-all-table
  $+  selected-all-table
  $:  %all-object
    =qualified-table
    ==
+$  selected-aggregate
  $+  selected-aggregate
  $:  %selected-aggregate
    =aggregate
    alias=(unit @t)
    ==
+$  selected-value
  $+  selected-value
  $:  %selected-value
    value=dime
    alias=(unit @t)
    ==
+$  aggregate
  $+  aggregate
  $:  %aggregate
    function=@t
    source=aggregate-source
    ==
+$  aggregate-source     $%(qualified-column unqualified-column)
+$  grouping-column      ?(qualified-column unqualified-column @ud)
+$  ordering-column
  $+  ordering-column
  $:  %ordering-column
    column=grouping-column
    ascending=?
    ==
+$  with
  $+  with
  $:  %with
    (list cte)
    ==
::
::  $crud-txn:
+$  crud-txn
  $+  crud-txn
  $:  %crud-txn
    ctes=(list cte)
    body=crud-body
    ==
::
::  $crud-body: terminal command of a crud-txn
+$  crud-body
  $+  crud-body
  $%  [%query query]
      [%set-query set-query]
      [%insert insert]
      [%delete delete]
      [%update update]
      [%merge merge]
  ==
::
::  $set-query: a sequence of queries joined by set operations
+$  set-query
  $+  set-query
  $:  %set-query
    head=query
    tail=(list [op=set-op =query])
    ==
+$  set-op
    $?  %union  %except  %intersect  %divided-by  %divide-with-remainder
    ==
::
::  $cte-body: body of a CTE (queries only; no DML to avoid circular type)
+$  cte-body
  $+  cte-body
  $%  [%query query]
      [%set-query set-query]
  ==
::  $cte:
+$  cte
  $+  cte
  $:  %cte
    name=@tas
    body=cte-body
    ==
::
::  data manipulation ASTs
::
::
::  $delete:
+$  delete
  $+  delete
  $:  %delete
    scalars=(list scalar)
    =qualified-table
    as-of=(unit as-of)
    =predicate
    ==
::
::  $update:
+$  update
  $+  update
  $:  %update
    scalars=(list scalar)
    =qualified-table
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
  $+  insert
  $:  %insert
    =qualified-table
    as-of=(unit as-of)
    columns=(unit (list @tas))
    values=insert-values
    ==
+$  value-or-default     ?(%default datum)
::
::  $merge: merge from source relation into target relation
+$  merge
  $+  merge
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
  $+  matching
  $:  %matching
    =predicate
    =matching-profile
    ==
+$  matching-action  ?(%insert %update %delete)
+$  matching-profile
  $%([%insert (list [@t datum])] [%update (list [@t datum])] %delete)
+$  matching-lists
  $+  matching-lists
  $:  matched=(list matching)
    not-target=(list matching)
    not-source=(list matching)
    ==
::
::  $truncate-table:
+$  truncate-table
  $+  truncate-table
  $:  %truncate-table
    =qualified-table
    as-of=(unit as-of)
    ==
::
::  create ASTs
::
+$  as-of-offset
  $+  as-of-offset
  $:  %as-of-offset
    offset=@ud
    units=?(%seconds %minutes %hours %days %weeks %months %years)
    ==
+$  as-of  ?([%da @da] [%dr @dr] as-of-offset)
::
::  $create-database: $:([%create-database name=@tas])
+$  create-database
  $+  create-database
  $:  %create-database
    name=@tas
    as-of=(unit as-of)
    ==
::
::  $create-index:
+$  create-index
  $+  create-index
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
  $+  create-namespace
  $:  %create-namespace
    database-name=@tas
    name=@tas
    as-of=(unit as-of)
    ==
::
::  $create-table
+$  create-table
  $+  create-table
  $:  %create-table
    =qualified-table
    columns=(list column)
    pri-indx=(list ordered-column)
    foreign-keys=(list foreign-key)
    as-of=(unit as-of)
    ==
::
::  $create-trigger: TBD
+$  create-trigger
  $+  create-trigger
  $:  %create-trigger
    name=@tas
    =qualified-table
    enabled=?
    ==
::
::  $create-type: TBD
+$  create-type
  $+  create-type
  $:  %create-type
    name=@tas
    ==
::
::  $create-view: persist a crud-txn as a view
+$  create-view
  $+  create-view
  $:  %create-view
    view=qualified-table
    crud-txn
    ==
::
::  drop ASTs
::
::  $drop-database: name=@tas force=?
+$  drop-database
  $+  drop-database
  $:  %drop-database
    name=@tas
    force=?
    ==
::
::  $drop-index: name=@tas object=qualified-table
+$  drop-index
  $+  drop-index
  $:  %drop-index
    name=@tas
    =qualified-table
    as-of=(unit as-of)
    ==
::
::  $drop-namespace: database-name=@tas name=@tas force=?
+$  drop-namespace
  $+  drop-namespace
  $:  %drop-namespace
    database-name=@tas
    name=@tas
    force=?
    as-of=(unit as-of)
    ==
::
::  $drop-table: =qualified-table force=?
+$  drop-table
  $+  drop-table
  $:  %drop-table
    =qualified-table
    force=?
    as-of=(unit as-of)
    ==
::
::  $drop-trigger: TBD
+$  drop-trigger
  $+  drop-trigger
  $:  %drop-trigger
    name=@tas
    =qualified-table
    ==
::
::  $drop-type: TBD
+$  drop-type
  $+  drop-type
  $:  %drop-type
    name=@tas
    ==
::
::  $drop-view: view=qualified-table force=?
+$  drop-view
  $+  drop-view
  $:  %drop-view
    view=qualified-table
    force=?
    ==
::
::  ALTER SCHEMA
::
::
::  $alter-index: change an index
+$  alter-index
  $+  alter-index
  $:  %alter-index
    name=@tas
    =qualified-table
    columns=(list ordered-column)
    action=index-action
    as-of=(unit as-of)
    ==
::
::  $alter-namespace: move an object from one namespace to another
+$  alter-namespace
  $+  alter-namespace
  $:  %alter-namespace
    database-name=@tas
    source-namespace=@tas
    object-type=table-or-view
    target-namespace=@tas
    target-name=@tas
    as-of=(unit as-of)
    ==
::
::  $alter-table: to do - this could be simpler
+$  alter-table
  $+  alter-table
  $:  %alter-table
    =qualified-table
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
  $+  alter-trigger
  $:  %alter-trigger
    name=@tas
    =qualified-table
    enabled=?
    ==
::
::  $alter-view: view=qualified-table crud-txn
+$  alter-view
  $+  alter-view
  $:  %alter-view
    view=qualified-table
    =crud-txn
    ==
::
::  SCALARS
::
+$  scalar
  $+  scalar
  $:  %scalar
    name=@tas
    f=scalar-function
    ==
::
+$  scalar-function
  $+  scalar-function
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
    lower
    ltrim
    patindex
    quotestring
    replace
    replicate
    reverse
    right
    rtrim
    string
    string-concat
    stuff
    substring
    trim
    upper
    ==
::
+$  scalar-name
  $+  scalar-name
  $:  %scalar-name
      name=@tas
      ==
::
+$  scalar-node
  $+  scalar-node
  $%  scalar-function
      scalar-name
      datum
      ==
::
+$  arithmetic
  $+  arithmetic
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
  $+  if-then-else
  $:  %if-then-else
    if=predicate
    then=scalar-node
    else=scalar-node
    ==
::
+$  case-when-then
  $+  case-when-then
  $:  %case-when-then
    when=$%(predicate scalar-node)
    then=scalar-node
    ==
::
+$  case
  $+  case
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
  $+  getutcdate
  $:  %getutcdate
    ~
  ==
::
+$  year
  $+  year
  $:  %year
    date=scalar-node
  ==
::
+$  month
  $+  month
  $:  %month
    date=scalar-node
  ==
::
+$  day
  $+  day
  $:  %day
    time-expression=scalar-node
  ==
::
+$  hour
  $+  hour
  $:  %hour
    time-expression=scalar-node
  ==
::
+$  minute
  $+  minute
  $:  %minute
    time-expression=scalar-node
  ==
::
+$  second
  $+  second
  $:  %second
    time-expression=scalar-node
  ==
+$  add-time
  $+  add-time
  $:  %add-time
    time-expression=scalar-node
    duration=scalar-node
  ==
+$  subtract-time
  $+  subtract-time
  $:  %subtract-time
    time-expression=scalar-node
    duration=scalar-node
  ==
::
::  mathematical functions
::
+$  abs
  $+  abs
  $:  %abs
    numeric-expression=scalar-node
  ==
::
+$  acos
  $+  acos
  $:  %acos
    numeric-expression=scalar-node
  ==
::
+$  asin
  $+  asin
  $:  %asin
    numeric-expression=scalar-node
  ==
::
+$  atan
  $+  atan
  $:  %atan
    numeric-expression=scalar-node
  ==
::
+$  atan2
  $+  atan2
  $:  %atan2
    numeric-expression-1=scalar-node
    numeric-expression-2=scalar-node
  ==
::
+$  ceiling
  $+  ceiling
  $:  %ceiling
    numeric-expression=scalar-node
  ==
::
+$  cos
  $+  cos
  $:  %cos
    numeric-expression=scalar-node
  ==
::
+$  degrees
  $+  degrees
  $:  %degrees
    numeric-expression=scalar-node
  ==
::
+$  e
  $+  e
  $:  %e
    ~
  ==
::
+$  floor
  $+  floor
  $:  %floor
    numeric-expression=scalar-node
  ==
::
+$  log
  $+  log
  $:  %log
    float-expression=scalar-node
    base=(unit scalar-node)
  ==
::
+$  max
  $+  max
  $:  %max
    numeric-expression-1=scalar-node
    numeric-expression-2=scalar-node
  ==
::
+$  min
  $+  min
  $:  %min
    numeric-expression-1=scalar-node
    numeric-expression-2=scalar-node
  ==
::
+$  phi
  $+  phi
  $:  %phi
    ~
  ==
::
+$  pi
  $+  pi
  $:  %pi
    ~
  ==
::
+$  rand
  $+  rand
  $:  %rand
    numeric-expression-1=scalar-node
    numeric-expression-2=scalar-node
  ==
::
+$  round
  $+  round
  $:  %round
    numeric-expression=scalar-node
    length=scalar-node
    ==
::
+$  sign
  $+  sign
  $:  %sign
    numeric-expression=scalar-node
  ==
::
+$  sin
  $+  sin
  $:  %sin
    numeric-expression=scalar-node
  ==
::
+$  sqrt
  $+  sqrt
  $:  %sqrt
    float-expression=scalar-node
  ==
::
+$  tan
  $+  tan
  $:  %tan
    numeric-expression=scalar-node
  ==
::
+$  tau
  $+  tau
  $:  %tau
    ~
  ==
::
::  string functions
::
+$  concat
  $+  concat
  :: if we remove this bucpat the type checker loops infinitely
  :: scalar-function -> concat -> scalar-node -> scalar-function
  $:  %concat
    args=$@(~ (list scalar-node))
  ==
::
+$  left
  $+  left
  $:  %left
    string-expression=scalar-node
    integer-expression=scalar-node
  ==
::
+$  len
  $+  len
  $:  %len
    string-expression=scalar-node
  ==
::
+$  lower
  $+  lower
  $:  %lower
    string-expression=scalar-node
  ==
::
::  unit @t default whitespace
+$  ltrim
  $+  ltrim
  $:  %ltrim
    string-expression=scalar-node
    pattern=(unit scalar-node)
  ==
::
::  Returns the starting position of the first occurrence of a pattern 
::  in a specified expression, or zero if the pattern isn't found
+$  patindex
  $+  patindex
  $:  %patindex
    string-expression=scalar-node
    pattern=scalar-node
  ==
::
::  default[]
+$  quotestring
  $+  quotestring
  $:  %quotestring
    string-expression=scalar-node
    quote=(unit [scalar-node scalar-node])
  ==
::
+$  replace
  $+  replace
  $:  %replace
    string-expression=scalar-node
    pattern=scalar-node
    replacement=scalar-node
  ==
::
+$  replicate
  $+  replicate
  $:  %replicate
    string-expression=scalar-node
    integer-expression=scalar-node
  ==
::
+$  reverse
  $+  reverse
  $:  %reverse
    string-expression=scalar-node
  ==
::
+$  right
  $+  right
  $:  %right
    string-expression=scalar-node
    integer-expression=scalar-node
  ==
::
::  unit @t default whitespace
+$  rtrim
  $+  rtrim
  $:  %rtrim
    string-expression=scalar-node
    pattern=(unit scalar-node)
  ==
::
::@ud @sd @rd -> @t  (scow %ud 123)
+$  string
  $+  string
  $:  %string
    numeric-expression=scalar-node
  ==
::
::  (list @t @ud @st @rd) @t
+$  string-concat
  $+  string-concat
  $:  %string-concat
    args=$@(~ (list scalar-node))
    delimiter=scalar-node
  ==
::
+$  stuff
  $+  stuff
  $:  %stuff
    string-expression=scalar-node
    start=scalar-node
    length=scalar-node
    replace=scalar-node
  ==
::
+$  substring
  $+  substring
  $:  %substring
    string-expression=scalar-node
    start=scalar-node
    length=(unit scalar-node)
    ==
::
+$  trim
  $+  trim
  $:  %trim
    string-expression=scalar-node
    pattern=(unit scalar-node)
  ==
+$  upper
  $+  upper
  $:  %upper
    string-expression=scalar-node
  ==
::
::  OUTPUT
::
+$  cmd-result  [%results (list result)]
+$  result
  $%
    [%action action=@t]
    [%relation relation=@t]
    [%message msg=@t]
    [%vector-count count=@ud]
    [%server-time date=@da]
    [%security-time date=@da]
    [%schema-time date=@da]
    [%data-time date=@da]
    [%result-set (list vector)]
    ==
::
+$  vector-cell  [p=@tas q=dime]
+$  vector
  $+  vector
  $:  %vector
    (lest vector-cell)
    ==
::
::  SECURITY PERMISSIONS
::
::
::  $grant-permission:  ?(%adminread %readonly %readwrite)
+$  grant-permission     ?(%adminread %readonly %readwrite)
::
::  $grantee: ?(%parent %siblings %moons %our @p)
::            $dime
+$  grantee
  $?
    %parent
    %siblings
    %moons
    %galaxies
    %stars
    %planets
    %comets
    %galaxy-moons
    %star-moons
    %planet-moons
    %all
    [%galaxy-moon @p]
    [%star-moon @p]
    [%planet-moon @p]
    [%our @tas]
    [%ship @p]
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
  $+  grant
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
  $+  revoke
  $:  %revoke
    permission=revoke-permission
    from=(list [dime (unit path)])
    revoke-target=(list revoke-object)
    duration=(unit sec-time)
    ==
::
::  $security-group
+$  security-group
  $+  security-group
  $:  %security-group
    grantees=(list [dime (unit path)])
    ==
::
::  $security-target
+$  security-target
  $+  security-target
  $:  %security-target
    grant-objects=(list grant-object)
    ==
--
