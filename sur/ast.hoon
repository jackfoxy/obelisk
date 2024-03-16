:: abstract syntax trees for urQL parsing and execution
::
|%
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
    transform
    truncate-table
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
  ?(%join %left-join %right-join %outer-join %outer-join-all %cross-join)
::
::  command component types
::
+$  value-literals
  $:
    %value-literals
    dime
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
+$  qualified-object
  $+  qualified-object
  $:
    %qualified-object
    ship=(unit @p)
    database=@tas
    namespace=@tas
    name=@tas
  ==
+$  qualified-column
  $+  qualified-column
  $:
    %qualified-column
    qualifier=qualified-object
    column=@tas
    alias=(unit @t)
  ==
+$  foreign-key
  $:
    %foreign-key
    name=@tas
    table=qualified-object
    columns=(list ordered-column)                    :: the source columns
    reference-table=qualified-object                 :: reference (target) table
    reference-columns=(list @t)                      :: and columns
                  :: what to do when referenced item deletes or updates
    referential-integrity=(list referential-integrity-action) 
  ==
::
::  expressions
::
:: { = | <> | != | > | >= | !> | < | <= | !< | BETWEEN...AND... 
::       | IS DISTINCT FROM | IS NOT DISTINCT FROM }
+$  ternary-op           ?(%between %not-between)
+$  inequality-op        ?(%neq %gt %gte %lt %lte)
+$  all-any-op           ?(%all %any)
+$  binary-op            ?(%eq inequality-op %equiv %not-equiv %in %not-in)
+$  unary-op             ?(%exists %not-exists)
+$  conjunction          ?(%and %or)
+$  ops-and-conjs        
      ?(ternary-op binary-op unary-op all-any-op conjunction)
+$  predicate-component  
      ?(ops-and-conjs qualified-column dime value-literals aggregate)
+$  predicate            (tree predicate-component)
+$  datum                $%(qualified-column dime)
+$  datum-or-scalar      $@(datum scalar-function)
+$  scalar-op            ?(%lus %tar %hep %fas %ket)
+$  scalar-token         ?(%pal %par scalar-op)
+$  arithmatic
  $:
    %arithmetic
    operator=scalar-op
    left=*                         :: datum-or-scalar
    right=*                        :: datum-or-scalar
  ==
+$  if-then-else
  $:
    %if-then-else
    if=*                           :: predicate
    then=*                         :: datum-or-scalar
    else=*                         :: datum-or-scalar
  ==
+$  case-when-then
  $:
    when=*                         :: predicate | datum
    then=*                         :: datum-or-scalar
  ==
+$  case
  $:
    %case
    target=datum
    cases=(list case-when-then)
    else=*                         :: datum-or-scalar
  ==
+$  coalesce
  $:
    %coalesce
    data=(list datum)
  ==
+$  scalar-function
  $%
    if-then-else
    case
    coalesce
  ==
::
::  query
::
::  $query:
+$  query
  $:
    %query
    from=(unit from)
    scalars=(list scalar-function)
    predicate=(unit predicate)
    group-by=(list grouping-column)
    having=(unit predicate)
    selection=select
    order-by=(list ordering-column)
  ==
::
::  $from:
+$  from
  $:
    %from
    object=table-set
    joins=(list joined-object)
  ==
+$  query-row
  $:
    %query-row
    (list @t)
  ==
+$  query-source  $%(query-row qualified-object)
::
::  $table-set:
+$  table-set
  $:
    %table-set
    object=query-source
    alias=(unit @t)
  ==
+$  joined-object
  $:
    %joined-object
    join=join-type
    object=table-set
    predicate=(unit predicate)
  ==
::
::  $select:
+$  select
  $:
    %select
    top=(unit @ud)
    bottom=(unit @ud)
    columns=(list selected-column)
  ==
+$  selected-column
  $%(qualified-column qualified-object selected-aggregate selected-value) 
  :: scalar-function or selected-scalar) fish-loop
+$  selected-aggregate
  $:
    %selected-aggregate
    aggregate=aggregate
    alias=(unit @t)
  ==
+$  selected-scalar
  $:
    %selected-scalar
    scalar=scalar-function
    alias=(unit @t)
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
::  $transform:
+$  transform
  $:
  %transform
  ctes=(list cte)
  set-functions=(tree set-function)
  ==
::
::  $cte:
+$  cte
  $:
    %cte
    name=@tas
    set-cmd
  ==
+$  set-op  
  $?
    %union
    %except
    %intersect
    %divided-by
    %divide-with-remainder
    %into
    %pass-thru
    %nop
    %tee
    %multee
  ==
+$  set-cmd       $%(delete insert update query merge)
+$  set-function  ?(set-op set-cmd)
::
::  data manipulation ASTs
::
::
::  $delete:
+$  delete
  $:
    %delete
    table=qualified-object
    predicate=(unit predicate)
    as-of=(unit as-of)
  ==
+$  insert-values      $%([%data (list (list value-or-default))] [%query query])
::
::  $insert:
+$  insert
  $:
    %insert
    table=qualified-object
    columns=(unit (list @t))
    values=insert-values
    as-of=(unit as-of)
  ==
+$  value-or-default     ?(%default datum)
::
::  $update:
+$  update
  $:
    %update
    table=qualified-object
    columns=(list @t)
    values=(list value-or-default)
    predicate=(unit predicate)
    as-of=(unit as-of)
  ==
::
::  $merge: merge from source table-set into target table-set
+$  merge
  $:
    %merge
    target-table=table-set
    new-table=(unit table-set)
    source-table=table-set
    predicate=predicate
    matched=(list matching)
    unmatched-by-target=(list matching)
    unmatched-by-source=(list matching)
    as-of=(unit as-of)
  ==
+$  matching
  $:
    %matching
    predicate=(unit predicate)
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
    table=qualified-object
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
+$  as-of  ?([%da @] [%dr @] as-of-offset)
::
::  $create-database: $:([%create-database name=@tas])
+$  create-database      $:([%create-database name=@tas as-of=(unit as-of)])
::
::  $create-index:
+$  create-index
  $:
    %create-index
    name=@tas
    object-name=qualified-object
    unique=?
    clustered=?
    columns=(list ordered-column)
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
    table=qualified-object
    columns=(list column)
    clustered=?
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
    object=qualified-object
    enabled=?
  ==
::
::  $create-type: TBD
+$  create-type          $:([%create-type name=@tas])
::
::  $create-view: persist a transform as a view
+$  create-view
  $:
    %create-view
    view=qualified-object
    transform
  ==
::
::  drop ASTs
::
::  $drop-database: name=@tas force=?
+$  drop-database        $:([%drop-database name=@tas force=?])
::
::  $drop-index: name=@tas object=qualified-object
+$  drop-index
  $:
    %drop-index
    name=@tas
    object=qualified-object
  ==
::
::  $drop-namespace: database-name=@tas name=@tas force=?
+$  drop-namespace       
  $:([%drop-namespace database-name=@tas name=@tas force=? as-of=(unit as-of)])
::
::  $drop-table: table=qualified-object force=?
+$  drop-table
  $:  %drop-table
    table=qualified-object
    force=?
    as-of=(unit as-of)
  ==
::
::  $drop-trigger: TBD
+$  drop-trigger
  $:
    %drop-trigger
    name=@tas
    object=qualified-object
  ==
::
::  $drop-type: TBD
+$  drop-type            $:([%drop-type name=@tas])
::
::  $drop-view: view=qualified-object force=?
+$  drop-view
  $:
    %drop-view
    view=qualified-object
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
    name=qualified-object
    object=qualified-object
    columns=(list ordered-column)
    action=index-action
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
    table=qualified-object
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
    object=qualified-object
    enabled=?
  ==
::
::  $alter-view: view=qualified-object transform
+$  alter-view
  $:
    %alter-view
    view=qualified-object
    transform
  ==
::
::  permissions
::
::
::  $grant-permission: ?(%adminread %readonly %readwrite)
+$  grant-permission     ?(%adminread %readonly %readwrite)
::
::  $grantee: ?(%parent %siblings %moons (list @p))
+$  grantee              ?(%parent %siblings %moons (list @p))
::
::  $revoke-permission: ?(%adminread %readonly %readwrite %all)
+$  revoke-permission    ?(%adminread %readonly %readwrite %all)
::
::  $revoke-from: ?(%parent %siblings %moons %all (list @p))
+$  revoke-from          ?(%parent %siblings %moons %all (list @p))
::
::  $grant-object: ?([%database @t] [%namespace [@t @t]] qualified-object)
+$  grant-object         ?([%database @t] [%namespace [@t @t]] qualified-object)
::
::  $grant: permission=grant-permission to=grantee grant-target=grant-object
+$  grant
  $:
    %grant
    permission=grant-permission
    to=grantee
    grant-target=grant-object
  ==
::
::  $revoke-object: ?([%database @t] [%namespace [@t @t]] %all qualified-object)
+$  revoke-object        
  ?([%database @t] [%namespace [@t @t]] %all qualified-object)
::
::  $revoke: permission=revoke-permission from=revoke-from revoke-target=revoke-object
+$  revoke
  $:
      %revoke
    permission=revoke-permission
    from=revoke-from
    revoke-target=revoke-object
  ==
--
