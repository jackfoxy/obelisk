/-  ast, *obelisk, *server-state-0
/+  *sys-views, *utils, *predicate, *scalars, mip
|_  [state=server =bowl:gall]
::
++  license
  ::  MIT+n license
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
++  select-relation
  ::  crud-txn from a single table without joins
  |=  [q=query:ast is-cte=? =named-ctes]
  ^-  [join-return (list vector)]
  =/  from          (normalize-from (need from.q))
  =/  =full-relation  %:  source-full-relation  relation.from
                                                named-ctes
                                                as-of.from
                                                ~
                                                ~
                                                *qualified-map-meta
                                                ~
                                                ==
  =/  selected      (normalize-selected columns.select.q)
  =/  qualifier-lookup
        (query-qualifier-lookup set-tables.full-relation)
  =/  resolved-scalars
        %:  resolve-query-scalars  scalars.q
                                   named-ctes
                                   qualifier-lookup
                                   map-meta.full-relation
                                   ==
  =/  filter        ?~  predicate.q  ~
                    :-  ~
                        %:  prepare-predicate
                            (pred-unqualify-qualified predicate.q)
                            :-  %unqualified-map-meta
                                %-  ~(got by +.map-meta.full-relation)
                                    qualifier.full-relation
                            ~
                            named-ctes
                            resolved-scalars
                            ==
  ::
  ?~  set-tables.full-relation  ~|("select-relation can't get here" !!)
  :-  :*  %join-return
          state
          ?.  is-cte   set-tables.full-relation
              %-  select-for-cte
              [q set-tables.full-relation filter named-ctes resolved-scalars]
          map-meta.full-relation
          column-metas.full-relation
          ==
      ?:  is-cte  *(list vector)
      %-  relation-vectors
      :*  filter
          column-metas.full-relation
          ?:  is-cte  map-meta.full-relation
          map-meta.i.set-tables.full-relation
          ?~  joined-rows.i.set-tables.full-relation
            indexed-rows.i.set-tables.full-relation
          joined-rows.i.set-tables.full-relation
          selected
          resolved-scalars
          named-ctes
          ==
::
++  join-all
  ::  server state returned because we may have updated the view cache
  |=  [q=query:ast =named-ctes]
  ^-  join-return
  =/  from  (normalize-from (need from.q))
  =/  joined-relations=(list joined-relat)
        %+  cross-joins-to-end  :*  %joined-relat
                                     ~
                                     relation.from
                                     as-of.from
                                     ~
                                     ==
                                 joins.from
  =/  relat=joined-relat  -.joined-relations
  =.  joined-relations    +.joined-relations
  =/  =full-relation  %:  source-full-relation  relation.relat
                                                named-ctes
                                                as-of.relat
                                                ~
                                                ~
                                                *qualified-map-meta
                                                ~
                                                ==
  =/  prior-join          -.set-tables.full-relation
  =/  from-objects        (limo ~[prior-join])
  |-
  ?~  joined-relations  (recalc-addr prior-join full-relation from-objects)
  =.  full-relation  %:  source-full-relation  relation.i.joined-relations
                                                named-ctes
                                                as-of.i.joined-relations
                                                join.i.joined-relations
                                                predicate.i.joined-relations
                                                map-meta.full-relation
                                                column-metas.full-relation
                                                ==
  =.  prior-join       %:  join-2-sets  prior-join
                                       -.set-tables.full-relation
                                       column-metas.full-relation
                                       ==
  %=  $
    joined-relations   +.joined-relations
    from-objects       [prior-join from-objects]
  ==
::
++  join-2-sets
  |=  [prior=set-table this=set-table column-metas=(list column-meta)]
  ^-  set-table
  ?-  (need join.this)
    %join
      ?:  =(~ predicate.this)  (join-natural prior this column-metas)
      (join-predicate prior this column-metas)
    %left-join
      ~|("%left-join not implemented" !!)
    %right-join
      ~|("right-join not implemented" !!)
    %outer-join
      ~|("%outer-join not implemented" !!)
    %cross-join
      (cross-join prior this)
  ==
::
++  join-natural
  |=  [prior=set-table this=set-table column-metas=(list column-meta)]
  ^-  set-table
  =/  this-key   key:(need pri-indx.this)
  =/  prior-key  key:(need pri-indx.prior)
  =/  rel-prior  (need relation.prior)
  =/  rel-this   (need relation.this)
  ::  accumulated columns from all prior source tables
  ::  (used for matching in multi-table joins where columns.prior
  ::  only has the most recent table's columns)
  =/  prior-accum-cols=(list column:ast)
    %+  murn  column-metas
    |=  cm=column-meta
    ^-  (unit column:ast)
    ?:  =(qualifier.qualified-column.cm rel-this)  ~
    [~ [%column name.qualified-column.cm type.cm addr.cm]]
  :: perfect natural join
  =/  count-and-rows  ?.  =(prior-key this-key)  [0 ~]
                      ?~  joined-rows.prior
                        %:  join-pri-key  indexed-rows.prior
                                          rel-prior
                                          indexed-rows.this
                                          rel-this
                                          this-key
                                        ==
                      %:  join-partial-key  joined-rows.prior
                                            rel-prior
                                            indexed-rows.this
                                            rel-this
                                            this-key
                                            ~
                                            ~
                                            ==
  ?:  =(prior-key this-key)
    (joined-set-table this -.count-and-rows +.count-and-rows)
  ::  key is same column sequence, but different ordering
  ?:  ?!  .=  (turn prior-key |=(a=key-column [name.a aura.a]))
              (turn this-key |=(a=key-column [name.a aura.a]))
    ::  partial key match
    =/  plen  (leading-prefix-len prior-key this-key)
    ?:  =(0 plen)
      ::  no key overlap, hash join on all matching columns
      =/  match-cols  (find-all-matches prior-accum-cols this)
      ?~  match-cols
        ~|  "no natural join or foreign key join, columns do not match: ".
            "{<rel-this>}"
            !!
      ::  check for ambiguous columns in multi-table join
      =/  ambig-col  (find-ambig-nonkey joined-rows.prior match-cols)
      ?^  ambig-col
        ~|  %-  crip
            %+  weld  "natural join: column %"
            %+  weld  (trip u.ambig-col)
                      " occurs in multiple tables"
            !!
      =/  prior-rows=(list data-row)
        ?~  joined-rows.prior  indexed-rows.prior
        joined-rows.prior
      =.  count-and-rows
        (join-hash prior-rows rel-prior indexed-rows.this rel-this match-cols)
      (joined-set-table this -.count-and-rows +.count-and-rows)
    =/  prior-prefix  (scag plen prior-key)
    =/  this-prefix   (scag plen this-key)
    =/  noncontig     (find-noncontig-matches prior-key this-key plen)
    =/  nonkey-cols   (find-nonkey-matches prior-accum-cols this prior-key this-key)
    ::  check for ambiguous non-key columns in multi-table join result
    =/  ambig-col  (find-ambig-nonkey joined-rows.prior nonkey-cols)
    ?^  ambig-col
      ~|  %-  crip
          %+  weld  "natural join: column %"
          %+  weld  (trip u.ambig-col)
                    " occurs in multiple tables"
          !!
    ::  check if prefix needs re-sort (different ASC/DESC)
    =/  needs-resort  ?!  .=  %+  turn  prior-prefix
                                  |=(a=key-column ascending.a)
                              %+  turn  this-prefix
                                  |=(a=key-column ascending.a)
    =/  sort-prefix   ?:  (gth rowcount.this rowcount.prior)
                        this-prefix
                      prior-prefix
    =/  used-prefix   ?:  needs-resort  sort-prefix
                      prior-prefix
    =/  prior-rows=(list data-row)
      ?~  joined-rows.prior  indexed-rows.prior
      joined-rows.prior
    =.  count-and-rows
      ?:  needs-resort
        ?:  (gth rowcount.this rowcount.prior)
          ::  sort prior by this's prefix order
          %:  join-partial-key
            %+  sort  prior-rows
              ~(order prefix-row-comp [plen (reduce-key sort-prefix)])
            rel-prior
            indexed-rows.this
            rel-this
            sort-prefix
            nonkey-cols
            noncontig
            ==
        ::  sort this by prior's prefix order
        %:  join-partial-key
          prior-rows
          rel-prior
          %+  sort  indexed-rows.this
            ~(order prefix-row-comp [plen (reduce-key sort-prefix)])
          rel-this
          sort-prefix
          nonkey-cols
          noncontig
          ==
      ::  same order, no re-sort needed
      %:  join-partial-key
        prior-rows
        rel-prior
        indexed-rows.this
        rel-this
        prior-prefix
        nonkey-cols
        noncontig
        ==
    (joined-set-table-pk this -.count-and-rows +.count-and-rows used-prefix)
  ::  sort the little one
  =/  the-key  ?:  (gth rowcount.this rowcount.prior)
                 this-key
               prior-key
  =.  count-and-rows
        ?:  (gth rowcount.this rowcount.prior)
          ?~  joined-rows.prior
            %:  join-pri-key  %+  sort  indexed-rows.prior
                                   ~(order data-row-comp (reduce-key the-key))
                              rel-prior
                              indexed-rows.this
                              rel-this
                              this-key
                              ==
          %:  join-partial-key  %+  sort  joined-rows.prior
                                     ~(order data-row-comp (reduce-key the-key))
                              rel-prior
                              indexed-rows.this
                              rel-this
                              this-key
                              ~
                              ~
                              ==
        ?~  joined-rows.prior
          %:  join-pri-key  indexed-rows.prior
                            rel-prior
                            %+  sort  indexed-rows.this
                                    ~(order data-row-comp (reduce-key the-key))
                            rel-this
                            prior-key
                            ==
        %:  join-partial-key  joined-rows.prior
                              rel-prior
                              %+  sort  indexed-rows.this
                                      ~(order data-row-comp (reduce-key the-key))
                              rel-this
                              prior-key
                              ~
                              ~
                              ==
  ::
  (joined-set-table this -.count-and-rows +.count-and-rows)
::
++  join-predicate
  ::  predicate join (JOIN ... ON ...)
  ::  currently only supports equality conditions with AND conjunctions
  |=  [prior=set-table this=set-table column-metas=(list column-meta)]
  ^-  set-table
  =/  rel-prior  (need relation.prior)
  =/  rel-this   (need relation.this)
  ::  validate and extract equi-join column pairs from predicate
  =/  raw-pairs  (extract-equi-pairs predicate.this)
  ::  resolve unqualified columns, validate existence, assign to prior/this
  =/  resolved  %+  turn  raw-pairs
    |=  [l=resolved-on-col r=resolved-on-col]
    ^-  [@tas @tas]
    ::  rebrand alias qualifiers to match execution-time relations
    =.  l  (rebrand-on-col l rel-prior rel-this)
    =.  r  (rebrand-on-col r rel-prior rel-this)
    ::  resolve unqualified columns first (with ambiguity check)
    =.  l  (resolve-on-col l rel-prior rel-this column-metas)
    =.  r  (resolve-on-col r rel-prior rel-this column-metas)
    ::  validate both columns exist
    =/  l-found  (col-exists-any l column-metas)
    ?.  l-found
      (on-col-not-found l column-metas)
    =/  r-found  (col-exists-any r column-metas)
    ?.  r-found
      (on-col-not-found r column-metas)
    ::  type check: both columns must have the same type
    =/  l-type  (get-on-col-type l column-metas)
    =/  r-type  (get-on-col-type r column-metas)
    ?.  =(l-type r-type)
      ~|  "type mismatch in ON predicate: %{(trip name.l)} is {<l-type>} ".
          "but %{(trip name.r)} is {<r-type>}"
          !!
    ::  determine which column belongs to prior and which to this
    =/  l-is-this   (col-in-relation l rel-this column-metas)
    =/  r-is-this   (col-in-relation r rel-this column-metas)
    ::  l=prior-side, r=this-side
    ?:  &(?!(l-is-this) r-is-this)  [name.l name.r]
    ::  l=this-side, r=prior-side
    ?:  &(l-is-this ?!(r-is-this))  [name.r name.l]
    ::  both are this-side or both are prior-side
    ~|("ON predicate must reference columns from different relations" !!)
  =/  prior-cols  (turn resolved |=(p=[@tas @tas] -.p))
  =/  this-cols   (turn resolved |=(p=[@tas @tas] +.p))
  ::  hash join with separate column name lists
  =/  prior-rows=(list data-row)
    ?~  joined-rows.prior  indexed-rows.prior
    joined-rows.prior
  =/  count-and-rows
    %:  join-predicate-hash
      prior-rows
      rel-prior
      indexed-rows.this
      rel-this
      prior-cols
      this-cols
    ==
  (joined-set-table this -.count-and-rows +.count-and-rows)
::
+$  resolved-on-col  [qualifier=(unit qualified-table:ast) name=@tas]
::
++  extract-equi-pairs
  ::  walk predicate tree, extract equality column pairs
  ::  crash if non-eq or non-AND found
  |=  p=predicate:ast
  ^-  (list [resolved-on-col resolved-on-col])
  ?~  p  ~
  ?.  ?=(ops-and-conjs:ast n.p)
    ~|("JOIN ON predicate only supports equality and AND conjunctions" !!)
  ?+  n.p
    ~|("JOIN ON predicate only supports equality and AND conjunctions" !!)
    %eq
      ?~  l.p  ~|("JOIN ON: malformed equality predicate" !!)
      ?~  r.p  ~|("JOIN ON: malformed equality predicate" !!)
      =/  lc  (on-pred-to-col n.l.p)
      =/  rc  (on-pred-to-col n.r.p)
      ~[[lc rc]]
    %and
      ?~  l.p  ~|("JOIN ON: malformed AND predicate" !!)
      ?~  r.p  ~|("JOIN ON: malformed AND predicate" !!)
      %+  weld  (extract-equi-pairs l.p)
                (extract-equi-pairs r.p)
  ==
::
++  on-pred-to-col
  ::  extract column reference from a predicate leaf node
  |=  a=predicate-component:ast
  ^-  resolved-on-col
  ?:  ?=(qualified-column:ast a)
    [[~ qualifier.a] name.a]
  ?:  ?=(unqualified-column:ast a)
    [~ name.a]
  ~|("JOIN ON predicate only supports column references" !!)
::
++  rebrand-on-col
  ::  rebrand a qualifier whose table name matches an execution-time
  ::  relation but whose database/namespace differ (CTE alias case)
  |=  [col=resolved-on-col rel-prior=qualified-table:ast rel-this=qualified-table:ast]
  ^-  resolved-on-col
  ?~  qualifier.col  col
  =/  q  u.qualifier.col
  ?:  .=  (normalize-qt-alias q)
          (normalize-qt-alias rel-prior)
    col
  ?:  .=  (normalize-qt-alias q)
          (normalize-qt-alias rel-this)
    col
  ::  qualifier doesn't match directly; try matching by table name
  ?:  =(name.q name.rel-prior)
    col(qualifier [~ rel-prior])
  ?:  =(name.q name.rel-this)
    col(qualifier [~ rel-this])
  col
::
++  resolve-on-col
  ::  resolve an unqualified ON column against available relations
  ::  crash if ambiguous (exists in multiple relations)
  |=  $:  col=resolved-on-col
          rel-prior=qualified-table:ast
          rel-this=qualified-table:ast
          column-metas=(list column-meta)
          ==
  ^-  resolved-on-col
  ?^  qualifier.col  col
  ::  count how many relations have this column
  =/  matches=(list qualified-table:ast)
    %+  murn  column-metas
    |=  cm=column-meta
    ^-  (unit qualified-table:ast)
    ?.  =(name.qualified-column.cm name.col)  ~
    [~ qualifier.qualified-column.cm]
  ::  deduplicate (same relation may appear multiple times for different columns)
  =/  unique=(list qualified-table:ast)
    %+  roll  matches
    |=  [qt=qualified-table:ast acc=(list qualified-table:ast)]
    ?:  %+  lien  acc
        |=(a=qualified-table:ast =(a qt))
      acc
    [qt acc]
  ?~  unique
    ~|  "column %{(trip name.col)} does not exist"  !!
  ?:  (gth (lent unique) 1)
    ~|  "column %{(trip name.col)} is ambiguous in ON predicate"  !!
  ::  resolved to single relation
  [qualifier=[~ i.unique] name.col]
::
++  col-in-relation
  ::  check if a resolved column exists in a specific relation
  |=  [col=resolved-on-col rel=qualified-table:ast column-metas=(list column-meta)]
  ^-  ?
  ?^  qualifier.col
    ::  qualified: check if the qualifier matches this relation
    .=  (normalize-qt-alias u.qualifier.col)
        (normalize-qt-alias rel)
  ::  unqualified: check if column name exists in this relation
  %+  lien  column-metas
  |=  cm=column-meta
  ?&  =(name.qualified-column.cm name.col)
      .=  (normalize-qt-alias qualifier.qualified-column.cm)
          (normalize-qt-alias rel)
  ==
::
++  col-exists-any
  ::  check if a column exists in any relation in column-metas
  |=  [col=resolved-on-col column-metas=(list column-meta)]
  ^-  ?
  ?^  qualifier.col
    %+  lien  column-metas
    |=  cm=column-meta
    ?&  =(name.qualified-column.cm name.col)
        .=  (normalize-qt-alias qualifier.qualified-column.cm)
            (normalize-qt-alias u.qualifier.col)
    ==
  %+  lien  column-metas
  |=  cm=column-meta
  =(name.qualified-column.cm name.col)
::
++  on-col-not-found
  ::  produce specific error when an ON column is not found
  |=  [col=resolved-on-col column-metas=(list column-meta)]
  =/  alias-text
    ?~  qualifier.col  ""
    ?~  alias.u.qualifier.col
      (trip name.u.qualifier.col)
    (trip (need alias.u.qualifier.col))
  ?~  qualifier.col
    ~|  "column %{(trip name.col)} does not exist"  !!
  ::  check if the qualifier (relation) itself is valid
  =/  rel-exists
    %+  lien  column-metas
    |=  cm=column-meta
    .=  (normalize-qt-alias qualifier.qualified-column.cm)
        (normalize-qt-alias u.qualifier.col)
  ?.  rel-exists
    ~|  "{alias-text} is not a valid relation reference"  !!
  ::  relation exists but column doesn't
  ~|  "column %{(trip name.col)} does not exist"  !!
::
++  get-on-col-type
  ::  get the type of a resolved ON column from column-metas
  |=  [col=resolved-on-col column-metas=(list column-meta)]
  ^-  @ta
  ?^  qualifier.col
    =/  match
      %+  skim  column-metas
      |=  cm=column-meta
      ?&  =(name.qualified-column.cm name.col)
          .=  (normalize-qt-alias qualifier.qualified-column.cm)
              (normalize-qt-alias u.qualifier.col)
      ==
    ?~  match
      ~|  "column %{(trip name.col)} does not exist"  !!
    type.i.match
  =/  match
    %+  skim  column-metas
    |=  cm=column-meta
    =(name.qualified-column.cm name.col)
  ?~  match
    ~|  "column %{(trip name.col)} does not exist"  !!
  type.i.match
::
++  join-predicate-hash
  ::  hash join for predicate joins with different column names per side
  ::  builds hash map on this-cols from b, probes with prior-cols from a
  |=  $:  a=(list data-row)
          a-qual=qualified-table:ast
          b=(list indexed-row)
          b-qual=qualified-table:ast
          a-cols=(list @tas)
          b-cols=(list @tas)
          ==
  ^-  [@ud (list joined-row)]
  ::  build hash map from b rows keyed by b-cols values
  =/  b-map=(map (list @) (list indexed-row))
    =/  m  *(map (list @) (list indexed-row))
    =/  rows  b
    |-
    ?~  rows  m
    =/  hash-key  (extract-match-key i.rows b-cols)
    ?~  hash-key  $(rows t.rows)
    =/  existing  (~(gut by m) u.hash-key ~)
    $(m (~(put by m) u.hash-key [i.rows existing]), rows t.rows)
  ::  probe a rows against hash map using a-cols
  =/  out  *(list joined-row)
  =/  cnt  0
  |-
  ?~  a  [cnt (flop out)]
  =/  hash-key  (extract-match-key i.a a-cols)
  ?~  hash-key  $(a t.a)
  =/  matches  (~(gut by b-map) u.hash-key ~)
  =/  b-rows  matches
  |-
  ?~  b-rows  ^$(a t.a)
  =/  jr=joined-row
    ?:  ?=(%joined-row -.i.a)
      [%joined-row ~ (~(put by data.i.a) b-qual data.i.b-rows)]
    :+  %joined-row  ~
    %-  ~(put by (~(put by *(map qualified-table:ast (map @tas @))) a-qual data.i.a))
    [b-qual data.i.b-rows]
  $(b-rows t.b-rows, out [jr out], cnt +(cnt))
::
++  cross-join
  |=  [prior=set-table this=set-table]
  ^-  set-table
  =/  a=(list data-row)  ?~  joined-rows.prior
                           indexed-rows.prior
                         joined-rows.prior
  =/  out-rows           *(list joined-row)
  =/  i  0
  ::
  |-
  ?~  a  (joined-set-table this i out-rows)
  =/  b  indexed-rows.this
  |-
  ?~  b  ^$(a t.a)
  %=  $ 
    out-rows  :-  ?:  ?=(%joined-row -.i.a)
                    :+  %joined-row
                        ~
                        (~(put by data.i.a) (need relation.this) data.i.b)
                  %:  joined-from-indexed  i.a
                                           (need relation.prior)
                                           i.b
                                           (need relation.this)
                                           ==
                  out-rows
    b  t.b
    i  +(i)
  ==
::
++  query-qualifier-lookup
  ::  Build lookup qualifier by column name for resolving unqualified columns in
  ::  scalar functions on a single relation.
  |=  sources=(list set-table)
  ^-  qualifier-lookup
  =/  lookup  *qualifier-lookup
  |-
  ?~  sources  lookup
  =/  source=set-table  i.sources
  ?~  relation.source  $(sources t.sources)
  =/  columns=(list column:ast)  columns.source
  |-
  ?~  columns  ^$(sources t.sources)
  =/  col=column:ast  -.columns
  %=  $
    columns  +.columns
    lookup   ?:  (~(has by lookup) name.col)
               %+  ~(put by lookup)
                      name.col
                      :-  (need relation.source)
                          (~(got by lookup) name.col)
             %+  ~(put by lookup)  name.col
                                   (limo ~[(need relation.source)])
  ==
::
++  resolve-query-scalars
  |=  $:  scalars=(list scalar:ast)
          =named-ctes
          =qualifier-lookup
          =map-meta
          ==
  ^-  resolved-scalars
  =/  out  *resolved-scalars
  =/  =seed  eny.bowl
  |-
  ?~  scalars  out
  =/  ps  %:  prepare-scalar  f.i.scalars
                              named-ctes
                              qualifier-lookup
                              map-meta
                              out
                              bowl
                              seed
                              ==
  =.  seed  -.ps
  %=  $
    scalars  t.scalars
    out      (~(put by out) name.i.scalars +.ps)
    seed     seed
  ==
::
++  select-for-cte
  ::  cons a set-table of the crud-txn
  ::  1) object=~
  ::  2) new list of columns
  ::  3) key preserved w/ updated names or not
  ::  4) indexed-rows index preserved or not
  ::  4.5) schema-tmsp=(unit @da)
  ::      data-tmsp=(unit @da)
  ::      =map-meta  delete those that do not exist
  ::      pri-indx=(unit index)
  ::      =predicate
  ::      pri-indexed=(tree [(list @) (map @tas @)])
  ::  5) row count
  |=  [q=query:ast set-tables=(list set-table) f=(unit $-(data-row ?)) =named-ctes =resolved-scalars]
  ^-  (list set-table)
  ?~  set-tables  ~|("select-for-cte can't get here" !!)
  =/  st2  i.set-tables
  =.  relation.st2      ~
  =/  col-map       (malt (turn columns.i.set-tables |=(a=column:ast [name.a a])))
  =/  flipped-cols  (flop columns.i.set-tables)
  =.  columns.st2     %-  flop
                        ^-  (list column:ast)  %-  zing
                            %+  turn  columns.select.q
                                      |=  a=selected-column:ast
                                      %-  selected-column-to-column
                                      [named-ctes col-map flipped-cols a resolved-scalars]
  
  =/  selected-cols   %^  fold  columns.select.q
                                *(map @tas [@tas (unit @t)])
                                (cury selected-table-cols columns.i.set-tables)
  =.  pri-indx.st2    ?~  pri-indx.i.set-tables  ~
                      =/  st-key  key:(need pri-indx.i.set-tables)
                      =/  count-key-cols  %^  fold  st-key
                                                    *(pair @ud (list key-column))
                                                    (cury count-keys selected-cols)
                      ?:  =(p.count-key-cols (lent st-key))
                        [~ [%index %.y q.count-key-cols]]
                      ~
  ?~  f  [st2 set-tables]
  =.  indexed-rows.st2  %+  skim  indexed-rows.st2
                                   |=(a=indexed-row ((need f) a))
  =.  rowcount.st2      (lent indexed-rows.st2)
  [st2 set-tables]
::
++  count-keys
  ::  If key exists in selected columns then count, emit, and potentially rename
  ::  to alias.
  |=  $:  key-lookup=(map @tas (pair @tas (unit @t)))
          a=key-column
          b=(pair @ud (list key-column))
          ==
  =/  found  (~(get by key-lookup) name.a)
  ?~  found  b
  =/  found2  (need found)
  ?~  q.found2  [+(p.b) [a q.b]]
  [+(p.b) [[%key-column (need q.found2) aura.a ascending.a] q.b]]
::
++  selected-table-cols
  ::  Create look-up from original table column name to name or alias in SELECT,
  ::  used in deciding if key is preserved and renaming key columns.
  |=  $:  all-cols=(list column:ast)
          a=selected-column:ast
          b=(map @tas [@tas (unit @t)])
          ==
  ^-  (map @tas [@tas (unit @t)])
  ?:  ?=(unqualified-column:ast a)
    (~(put by b) name.a [name.a alias.a])
  ?:  ?=(qualified-column:ast a)
    (~(put by b) name.a [name.a alias.a])
  ?:  ?=(selected-all:ast a)
    |-
    ?~  all-cols  b
    %=  $
      all-cols  t.all-cols
      b         (~(put by b) name.i.all-cols [name.i.all-cols ~])
    ==
  ?:  ?=(selected-all-table:ast a)
    |-
    ?~  all-cols  b
    %=  $
      all-cols  t.all-cols
      b         (~(put by b) name.i.all-cols [name.i.all-cols ~])
    ==
  ?:  ?=(selected-cte-column:ast a)
    (~(put by b) name.a [name.a alias.a])
  b
::
++  selected-column-to-column
  |=  $:  =named-ctes
          col-map=(map @tas column:ast)
          flipped-cols=(list column:ast)
          =selected-column:ast
          =resolved-scalars
          ==
  ^-  (list column:ast)
  ?-  selected-column
    qualified-column:ast
      ~|("{<selected-column>} not supported" !!)
    unqualified-column:ast
      ~[(~(got by col-map) name.selected-column)]
    selected-aggregate:ast
      ~|("{<selected-column>} not supported" !!)
    selected-scalar:ast
      =/  rs=resolved-scalar
        ~|  "{<selected-column>} not in resolved-scalars"
        (~(got by resolved-scalars) name.selected-column)
      ~[[%column (heading selected-column name.selected-column) (resolved-scalar-type rs) 0]]
    selected-value:ast
      ~[[%column `@tas`(need alias.selected-column) p.value.selected-column 0]]
    selected-all:ast
      flipped-cols
    selected-all-table:ast
      flipped-cols
    selected-cte-column:ast
      =/  cte-fr  (~(got by named-ctes) cte.selected-column)
      =/  ta=typ-addr  %+  ~(got bi:mip +.map-meta.cte-fr)  [%cte-name cte.selected-column ~]
                                                              name.selected-column
      ~[[%column (heading selected-column name.selected-column) type.ta 0]]
    ==
::
++  relation-vectors
  ::  tree address of indexed/joined rows off by one
  ::  need sample column to determin path
  |=  $:  filter=(unit $-(data-row ?))
          column-metas=(list column-meta)
          =map-meta
          rows=(list data-row)
          selected=(list selected-column:ast)
          =resolved-scalars
          =named-ctes
          ==
  ^-  (list vector)
  ?~  rows         *(list vector)
  =/  out-rows     *(set vector)
  =/  templ-cells=(list templ-cell)
    %-  mk-rel-vect-templ
    [column-metas selected -.rows map-meta resolved-scalars named-ctes]
  ::
  ?~  templ-cells  ~|("relation-vectors can't get here" !!)
  =/  non-lit  %-  |=  a=(list templ-cell)
                   |-  ^-  (unit templ-cell) 
                   ?~  a  ~
                   ?~  column.i.a  $(a t.a)  [~ i.a]
                   templ-cells
  ?~  non-lit
    ?-  -.i.rows
      %joined-row  (joined-results filter ;;((list joined-row) rows) templ-cells)
      %indexed-row  (indexed-results filter ;;((list indexed-row) rows) templ-cells)
    ==
  =/  x        .*(data.i.rows [%0 addr:(need non-lit)])
  ?@  x        (joined-results filter ;;((list joined-row) rows) templ-cells)
  (indexed-results filter ;;((list indexed-row) rows) templ-cells)
::
++  indexed-results
  |=  $:  filter=(unit $-(data-row ?))
          rows=(list indexed-row)
          templ-cells=(list templ-cell)
          ==
  ^-  (list vector)
  =/  out-rows   *(set vector)
  |-
  ?~  rows  ~(tap in out-rows)
  =/  include-row=?
    ?~  filter
      %.y
    ((need filter) i.rows)
  ?.  include-row
    $(rows t.rows)
  =/  row                     *(list vector-cell:ast)
  =/  cols=(list templ-cell)  templ-cells
  |-
  ?~  cols
    %=  ^$
      out-rows  (~(put in out-rows) (vector %vector row))
      rows      t.rows
    ==
  ?^  scalar.i.cols
    =/  x=dime  (resolve-selected-scalar i.rows (need scalar.i.cols))
    $(cols t.cols, row [[p.vc.i.cols [p.x q.x]] row])
  ?~  column.i.cols    :: literal
    $(cols t.cols, row [vc.i.cols row])
  %=  $
    cols  t.cols
    row   :-  :-  p.vc.i.cols
                  [p.q.vc.i.cols ;;(@ +:.*(data.i.rows [%0 addr.i.cols]))]
              row
  ==
::
++  joined-results
  |=  $:  filter=(unit $-(data-row ?))
          rows=(list joined-row)
          templ-cells=(list templ-cell)
          ==
  ^-  (list vector)
  =/  out-rows   *(set vector)
  |-
  ?~  rows  ~(tap in out-rows)
  =/  include-row=?
    ?~  filter
      %.y
    ((need filter) i.rows)
  ?.  include-row
    $(rows t.rows)
  =/  row                     *(list vector-cell:ast)
  =/  cols=(list templ-cell)  templ-cells
  |-
  ?~  cols
    %=  ^$
      out-rows  (~(put in out-rows) (vector %vector row))
      rows      t.rows
    ==
  ?^  scalar.i.cols
    =/  x=dime  (resolve-selected-scalar i.rows (need scalar.i.cols))
    $(cols t.cols, row [[p.vc.i.cols [p.x q.x]] row])
  ?~  column.i.cols    :: literal
    $(cols t.cols, row [vc.i.cols row])
  %=  $
    cols  t.cols
    row   :-  :-  p.vc.i.cols
                  [p.q.vc.i.cols ;;(@ .*(data.i.rows [%0 addr.i.cols]))]
              row
  ==
::
++  recalc-addr
  ::  recalculate addr for joined data structure
  |=  [=set-table =full-relation from-objects=(list set-table)]
  ?~  joined-rows.set-table
    :*  %join-return
                      state
                      from-objects
                      map-meta.full-relation
                      column-metas.full-relation
                      ==
  =/  r=[(list column-meta) qualified-map-meta]
    %^  spin  column-metas.full-relation
              *qualified-map-meta
              |=  [=column-meta mm=qualified-map-meta]
              =/  new-addr
                    %^  calc-joined-addr  data.i.joined-rows.set-table
                                          qualifier.qualified-column.column-meta
                                          name.qualified-column.column-meta
              =.  addr.column-meta  new-addr
              :-  column-meta
                  :-  %qualified-map-meta
                      %^  ~(put bi:mip +.mm)
                            qualifier.qualified-column.column-meta
                            name.qualified-column.column-meta
                            [type.column-meta new-addr]
  :*  %join-return
                    state
                    from-objects
                    +.r
                    -.r
                    ==
::
++  source-full-relation
  |=  $:  rel=relation:ast
          =named-ctes
          as-of=(unit as-of:ast)
          join=(unit join-type:ast)
          =predicate
          map-meta=qualified-map-meta
          column-metas=(list column-meta)
          ==
  ^-  full-relation
  ?-  -.rel
    %qualified-table
      =/  qt=qualified-table:ast  rel
      =/  sys-time=@da  (set-tmsp as-of now.bowl)
      =/  db=database   ~|  "SELECT: database {<database.qt>} does not exist"
                         (~(got by state) database.qt)
      =/  =schema       ~|  "SELECT: database {<database.qt>} ".
                          "doesn't exist at time {<sys-time>}"
                          (get-schema [sys.db sys-time])
      %:  got-relation  qt
                        named-ctes
                        as-of
                        db
                        schema
                        join
                        predicate
                        map-meta
                        column-metas
                        ==
    %cte-name
      =/  cn  ;;(cte-name:ast rel)
      %:  from-cte  :*  %qualified-table
                        ship=~
                        database=%cte
                        namespace=%cte
                        name=name.cn
                        alias=alias.cn
                        ==
                    named-ctes
                    *schema
                    join
                    predicate
                    map-meta
                    column-metas
                    ==
    %query-row
      ~|("SELECT: not supported on %query-row" !!)
  ==
::
++  got-relation
  ::  branches to +from-table if not a view
  |=  $:  =qualified-table:ast
          =named-ctes
          as-of=(unit as-of:ast)
          db=database
          =schema
          join=(unit join-type:ast)
          =predicate
          map-meta=qualified-map-meta
          column-metas=(list column-meta)
          ==
  ^-  full-relation
  =/  sys-time   (set-tmsp as-of now.bowl)
  =/  vw  %+  get-view
                [namespace.qualified-table name.qualified-table sys-time]
                views.schema
  ?~  vw  %:  from-table  qualified-table
                          named-ctes
                          db
                          schema
                          join
                          predicate
                          sys-time
                          map-meta
                          column-metas
                          ==
  =/  vw2=view  (need vw)
  =/  r=[? database cache]  %:  got-view-cache  db
                                                schema
                                                vw2
                                                :+  namespace.qualified-table
                                                    name.qualified-table
                                                    sys-time
                                                ==
  =/  view-content  (need content.+>.r)
  ::
  ::  database view cache may have been populated
  =.  state  ?:  -.r
                (~(put by state) name.db +<.r)
             state
  :*  %full-relation
      qualified-table
      :~  :*  %set-table
              join
              [~ qualified-table]
              [~ tmsp.schema]
              [~ tmsp.+.r]
              columns.vw2
              predicate
              rowcount.view-content
              [%unqualified-map-meta typ-addr-lookup.vw2]
              ~
              ~
              %+  turn  rows.view-content
                   |=(a=(map @tas @) [%indexed-row ~ a])
              *(list joined-row)
              ==
          ==
      :-  %qualified-map-meta
          %+  ~(put by *(map qualifier (map @tas typ-addr)))
                qualified-table
                typ-addr-lookup.vw2
      (mk-column-metas qualified-table column-metas columns.vw2)
      ==
::
++  from-table
  :: if table doesn't exist, it can only be a CTE
  |=  $:  =qualified-table:ast
          =named-ctes
          db=database
          =schema
          join=(unit join-type:ast)
          =predicate
          sys-time=@da
          map-meta=qualified-map-meta
          column-metas=(list column-meta)
          ==
  ^-  full-relation
  =/  tbl  %-  ~(get by tables.schema)
               [namespace.qualified-table name.qualified-table]
  ?~  tbl  %:  from-cte  qualified-table
                         named-ctes
                         schema
                         join
                         predicate
                         map-meta
                         column-metas
                         ==
  =/  tbl2=table  (need tbl)
  =/  file  %^  get-content  content.db
                             sys-time
                             [namespace.qualified-table name.qualified-table]
  :*  %full-relation
      qualified-table
      :~  :*  %set-table
              join
              [~ qualified-table]
              [~ tmsp.tbl2]
              [~ tmsp.file]
              columns.tbl2
              predicate
              rowcount.file
              [%unqualified-map-meta typ-addr-lookup.tbl2]
              [~ pri-indx.tbl2]
              pri-idx.file
              indexed-rows.file
              *(list joined-row)
              ==
          ==
      :-  %qualified-map-meta
          (~(put by +.map-meta) qualified-table typ-addr-lookup.tbl2)
      (mk-column-metas qualified-table column-metas columns.tbl2)
      ==
::
++  from-cte
  ::  wrap a CTE as an opaque relation so its internal
  ::  source tables don't leak into canonical-list
  |=  $:  =qualified-table:ast
          =named-ctes
          =schema
          join=(unit join-type:ast)
          =predicate
          map-meta=qualified-map-meta
          column-metas=(list column-meta)
          ==
  ^-  full-relation
  =/  norm-qt  (normalize-qt-alias qualified-table)
  =/  cte-fr  ~|  "SELECT: table {<database.qualified-table>}.".
                  "{<namespace.qualified-table>}.{<name.qualified-table>} ".
                  "does not exist at schema time {<tmsp.schema>}"
              (~(got by named-ctes) name.qualified-table)
  ?~  set-tables.cte-fr  ~|("from-cte: empty set-tables" !!)
  =/  cte-st  i.set-tables.cte-fr
  =.  relation.cte-st  [~ norm-qt]
  =.  join.cte-st      join
  =.  predicate.cte-st  predicate
  =/  cte-col-meta
    (need (~(get by +.map-meta.cte-fr) [%cte-name name.qualified-table ~]))
  :*  %full-relation
      norm-qt
      [cte-st ~]
      :-  %qualified-map-meta
          (~(put by +.map-meta) norm-qt cte-col-meta)
      ::  use CTE's original column-metas (correct addr from
      ::  calc-joined-addr for JOINs) rebranded to outer qualified-table
      %+  weld  column-metas
      %+  turn  column-metas.cte-fr
      |=  cm=column-meta
      :+  :^  %qualified-column
              norm-qt
              name.qualified-column.cm
              alias.qualified-column.cm
          type.cm
          addr.cm
      ==
::
++  cross-joins-to-end
  ::  put all cross joins at the end of the list
  |=  [relat=joined-relat joins=(list joined-relation:ast)]
  ^-  (list joined-relat)
  =/  joined-relations=(list joined-relat)    ~[relat]
  =/  cross-joins  *(list joined-relat)
  |-
  ?~  joins  (flop (weld cross-joins joined-relations))
  ?:  ?=(%cross-join join-type.i.joins)
    %=  $
      joins  t.joins
      cross-joins  :-  :*  %joined-relat
                           `join-type.i.joins
                            relation.i.joins
                            as-of.i.joins
                            predicate.i.joins
                            ==
                       cross-joins
    ==
  %=  $
    joins  t.joins
    joined-relations  :-  :*  %joined-relat
                              `join-type.i.joins
                              relation.i.joins
                              as-of.i.joins
                              predicate.i.joins
                              ==
                   joined-relations
  ==
::
++  got-view-cache
  |=  [db=database =schema vw=view key=ns-rel-key]
  ^-  [? database cache]
  =/  vw-cache=cache  (get-view-cache key view-cache.db)
  ?.  =(content.vw-cache ~)  [%.n db vw-cache]
  =.  content.vw-cache  ?:  =(ns.key 'sys')
                              :-  ~
                                  %:  populate-system-view  state
                                                            db
                                                            schema
                                                            vw
                                                            rel.key
                                                            tmsp.vw-cache
                                                            ==
                                !!  :: : implement view refresh for non-sys
  [%.y (put-view-cache db vw-cache key) vw-cache]
::
++  reduce-ord-col
  |=  a=ordered-column:ast
  ^-  @tas
  name.a
::
++  joined-set-table
  |=  [st=set-table row-count=@ud joined-rows=(list joined-row)]
  ^-  set-table
  =.  rowcount.st     row-count
  =.  joined-rows.st  joined-rows
  st
::
++  join-pri-key
  ::  joins the data of two tables having the same key
  |=  $:  a=(list data-row)
          a-qual=qualified-table:ast
          b=(list indexed-row)
          b-qual=qualified-table:ast
          key=(list key-column)
          ==
  ^-  [@ud (list joined-row)]
  =/  c  *(list joined-row)
  =/  i  0
  ::
  |-
  ?~  a  [i (flop c)]
  ?~  b  [i (flop c)]
  ?:  =(key.i.a key.i.b)
    %=  $ 
      c  ?:  ?=(%joined-row -.i.a) 
        [[%joined-row key.i.a (~(put by data.i.a) b-qual data.i.b)] c]
      [(joined-from-indexed i.a a-qual i.b b-qual) c]
      a  t.a
      b  t.b
      i  +(i)
    ==
  ?:  (~(order idx-comp (reduce-key key)) key.i.a key.i.b)
    $(a t.a)
  $(b t.b)
::
++  joined-from-indexed
  |=  $:  a=indexed-row
          a-qual=qualified-table:ast
          b=indexed-row
          b-qual=qualified-table:ast
          ==
  ^-  joined-row
  :+  %joined-row
      key.a
      %+  %~  put  by  %+  %~  put  by  *(map qualified-table:ast (map @tas @))
                           a-qual
                           data.a
          b-qual
          data.b
::
++  data-row-comp
  ::
  ::  comparator for index mops
  |_  index=(list [@tas ?])
  ++  order
    |=  [a=[data-row] b=[data-row]]
    =/  p  key.a
    =/  q  key.b
    =/  k=(list [@tas ?])  index
    |-  ^-  ?
    ?:  =(-.p -.q)  $(k +.k, p +.p, q +.q)
    ?:  =(-<.k %t)  (alpha -.q -.p)
    ?:  =(-<.k %rd)
      ?:  ->.k  (gth:rd -.p -.q)
      (lth:rd -.p -.q)
    ?:  =(-<.k %sd)
      ?:  ->.k  =((cmp:si `@s`-.p `@s`-.q) --1)
      =((cmp:si `@s`-.p `@s`-.q) -1)
    ?:  ->.k  (gth -.p -.q)
    (lth -.p -.q)
  --
++  prefix-row-comp
  ::
  ::  comparator for sorting by leading prefix columns only
  |_  [plen=@ud index=(list [@ta ?])]
  ++  order
    |=  [a=[data-row] b=[data-row]]
    =/  p  (scag plen key.a)
    =/  q  (scag plen key.b)
    =/  k=(list [@ta ?])  index
    |-  ^-  ?
    ?~  p  %.n
    ?:  =(-.p -.q)  $(k +.k, p +.p, q +.q)
    ?:  =(-<.k %t)  (alpha -.q -.p)
    ?:  =(-<.k %rd)
      ?:  ->.k  (gth:rd -.p -.q)
      (lth:rd -.p -.q)
    ?:  =(-<.k %sd)
      ?:  ->.k  =((cmp:si `@s`-.p `@s`-.q) --1)
      =((cmp:si `@s`-.p `@s`-.q) -1)
    ?:  ->.k  (gth -.p -.q)
    (lth -.p -.q)
  --
::
++  joined-set-table-pk
  ::  build result set-table for partial key join
  |=  $:  st=set-table
          row-count=@ud
          joined-rows=(list joined-row)
          pk=(list key-column)
          ==
  ^-  set-table
  =.  rowcount.st     row-count
  =.  joined-rows.st  joined-rows
  =.  pri-indx.st     [~ [%index %.y pk]]
  st
::
++  leading-prefix-len
  ::  count leading columns matching by name+aura
  |=  [a=(list key-column) b=(list key-column)]
  ^-  @ud
  =/  i  0
  |-
  ?~  a  i
  ?~  b  i
  ?.  =([name.i.a aura.i.a] [name.i.b aura.i.b])  i
  $(a t.a, b t.b, i +(i))
::
++  find-noncontig-matches
  ::  find key column matches beyond the leading prefix
  ::  returns (list [prior-key-pos this-key-pos])
  |=  $:  prior-key=(list key-column)
          this-key=(list key-column)
          plen=@ud
          ==
  ^-  (list [@ud @ud])
  =/  prior-rest  (slag plen prior-key)
  =/  this-rest   (slag plen this-key)
  ::  build lookup from name+aura to absolute position for prior's remaining cols
  =/  prior-lookup=(map [@tas @ta] @ud)
    %-  malt
    =/  idx  plen
    =/  rest  prior-rest
    =/  out  *(list [[@tas @ta] @ud])
    |-
    ?~  rest  out
    $(out [[[name.i.rest aura.i.rest] idx] out], rest t.rest, idx +(idx))
  ::  walk this-rest and find matches
  =/  out  *(list [@ud @ud])
  =/  this-idx  plen
  |-
  ?~  this-rest  (flop out)
  =/  prior-idx  (~(get by prior-lookup) [name.i.this-rest aura.i.this-rest])
  =.  out  ?~  prior-idx  out
           [[u.prior-idx this-idx] out]
  $(this-rest t.this-rest, this-idx +(this-idx))
::
++  find-nonkey-matches
  ::  find non-key columns matching by name+type between prior and this
  ::  prior-cols: accumulated columns from all prior source tables
  |=  $:  prior-cols=(list column:ast)
          this=set-table
          prior-key=(list key-column)
          this-key=(list key-column)
          ==
  ^-  (list @tas)
  =/  prior-key-names  (silt (turn prior-key |=(a=key-column name.a)))
  =/  this-key-names   (silt (turn this-key |=(a=key-column name.a)))
  =/  prior-nonkey  %+  skip  prior-cols
                    |=(c=column:ast (~(has in prior-key-names) name.c))
  =/  this-nonkey   %+  skip  columns.this
                    |=(c=column:ast (~(has in this-key-names) name.c))
  =/  this-lookup   (malt (turn this-nonkey |=(c=column:ast [name.c type.c])))
  %+  murn  prior-nonkey
  |=  c=column:ast
  ^-  (unit @tas)
  =/  match  (~(get by this-lookup) name.c)
  ?~  match  ~
  ?.  =(u.match type.c)  ~
  [~ name.c]
::
++  find-ambig-nonkey
  ::  check if any non-key column exists in multiple source tables
  |=  [jrows=(list joined-row) cols=(list @tas)]
  ^-  (unit @tas)
  ?~  jrows  ~
  =/  rels  ~(tap by data.i.jrows)
  |-
  ?~  cols  ~
  =/  cnt  %+  roll  rels
    |=  [r=[qualified-table:ast (map @tas @)] cnt=@ud]
    ?:  (~(has by +.r) i.cols)  +(cnt)
    cnt
  ?:  (gth cnt 1)  [~ i.cols]
  $(cols t.cols)
::
++  get-col-from-row
  ::  extract a column value from any data-row by name
  |=  [col=@tas row=data-row]
  ^-  (unit @)
  ?:  ?=(%indexed-row -.row)
    (~(get by data.row) col)
  ::  joined-row: search all relations in the mip
  ?>  ?=(%joined-row -.row)
  =/  rels  ~(tap by data.row)
  |-
  ?~  rels  ~
  =/  val  (~(get by q.i.rels) col)
  ?^  val  val
  $(rels t.rels)
::
++  find-all-matches
  ::  find all columns matching by name+type between prior and this
  ::  includes key columns (unlike find-nonkey-matches)
  ::  prior-cols: accumulated columns from all prior source tables
  |=  [prior-cols=(list column:ast) this=set-table]
  ^-  (list @tas)
  =/  this-lookup  (malt (turn columns.this |=(c=column:ast [name.c type.c])))
  %+  murn  prior-cols
  |=  c=column:ast
  ^-  (unit @tas)
  =/  match  (~(get by this-lookup) name.c)
  ?~  match  ~
  ?.  =(u.match type.c)  ~
  [~ name.c]
::
++  extract-match-key
  ::  extract values for matching columns from a data-row
  ::  returns ~ if any column is missing
  |=  [row=data-row cols=(list @tas)]
  ^-  (unit (list @))
  =/  vals  *(list @)
  |-
  ?~  cols  [~ (flop vals)]
  =/  v  (get-col-from-row i.cols row)
  ?~  v  ~
  $(cols t.cols, vals [u.v vals])
::
++  join-hash
  ::  hash join for tables with no primary key overlap
  ::  builds hash map on matching columns from b, probes with a
  |=  $:  a=(list data-row)
          a-qual=qualified-table:ast
          b=(list indexed-row)
          b-qual=qualified-table:ast
          match-cols=(list @tas)
          ==
  ^-  [@ud (list joined-row)]
  ::  build hash map from b rows keyed by matching column values
  =/  b-map=(map (list @) (list indexed-row))
    =/  m  *(map (list @) (list indexed-row))
    =/  rows  b
    |-
    ?~  rows  m
    =/  hash-key  (extract-match-key i.rows match-cols)
    ?~  hash-key  $(rows t.rows)
    =/  existing  (~(gut by m) u.hash-key ~)
    $(m (~(put by m) u.hash-key [i.rows existing]), rows t.rows)
  ::  probe a rows against hash map
  =/  out  *(list joined-row)
  =/  cnt  0
  |-
  ?~  a  [cnt (flop out)]
  =/  hash-key  (extract-match-key i.a match-cols)
  ?~  hash-key  $(a t.a)
  =/  matches  (~(gut by b-map) u.hash-key ~)
  =/  b-rows  matches
  |-
  ?~  b-rows  ^$(a t.a)
  =/  jr=joined-row
    ?:  ?=(%joined-row -.i.a)
      [%joined-row ~ (~(put by data.i.a) b-qual data.i.b-rows)]
    :+  %joined-row  ~
    %-  ~(put by (~(put by *(map qualified-table:ast (map @tas @))) a-qual data.i.a))
    [b-qual data.i.b-rows]
  $(b-rows t.b-rows, out [jr out], cnt +(cnt))
::
++  collect-group
  ::  collect consecutive rows sharing the same prefix key
  |=  [rows=(list data-row) prefix=(list @) plen=@ud]
  ^-  [(list data-row) (list data-row)]
  =/  group  *(list data-row)
  |-
  ?~  rows  [(flop group) ~]
  ?.  =(prefix (scag plen key.i.rows))  [(flop group) rows]
  $(group [i.rows group], rows t.rows)
::
++  join-partial-key
  ::  merge-join on shared prefix key with group-based cross product
  |=  $:  a=(list data-row)
          a-qual=qualified-table:ast
          b=(list data-row)
          b-qual=qualified-table:ast
          prefix-key=(list key-column)
          nonkey-cols=(list @tas)
          noncontig=(list [@ud @ud])
          ==
  ^-  [@ud (list joined-row)]
  =/  c  *(list joined-row)
  =/  i  0
  =/  plen  (lent prefix-key)
  =/  prefix-idx  (reduce-key prefix-key)
  ::
  |-
  ?~  a  [i (flop c)]
  ?~  b  [i (flop c)]
  =/  pa  (scag plen key.i.a)
  =/  pb  (scag plen key.i.b)
  ?:  =(pa pb)
    ::  collect all consecutive rows with same prefix from each side
    =/  ga  (collect-group a pa plen)
    =/  gb  (collect-group b pa plen)
    ::  cross-product with filtering
    =/  cross  %:  cross-filter
                 -.ga
                 -.gb
                 a-qual
                 b-qual
                 pa
                 nonkey-cols
                 noncontig
                 ==
    %=  $
      a  +.ga
      b  +.gb
      c  (weld -.cross c)
      i  (add i +.cross)
    ==
  ?:  (~(order idx-comp prefix-idx) pa pb)
    $(a t.a)
  $(b t.b)
::
++  cross-filter
  ::  cross-product of two groups, filtering on non-key and non-contiguous matches
  |=  $:  ga=(list data-row)
          gb=(list data-row)
          a-qual=qualified-table:ast
          b-qual=qualified-table:ast
          prefix=(list @)
          nonkey-cols=(list @tas)
          noncontig=(list [@ud @ud])
          ==
  ^-  [(list joined-row) @ud]
  =/  out  *(list joined-row)
  =/  cnt  0
  |-
  ?~  ga  [out cnt]
  =/  b-rows  gb
  |-
  ?~  b-rows  ^$(ga t.ga)
  ::  check non-contiguous key column matches
  ?.  (check-noncontig key.i.ga key.i.b-rows noncontig)
    $(b-rows t.b-rows)
  ::  check non-key column matches
  ?.  (check-nonkey-cols i.ga i.b-rows nonkey-cols)
    $(b-rows t.b-rows)
  ::  emit joined row with PREFIX key
  ?>  ?=(%indexed-row -.i.b-rows)
  =/  jr=joined-row
    ?:  ?=(%joined-row -.i.ga)
      [%joined-row prefix (~(put by data.i.ga) b-qual data.i.b-rows)]
    :+  %joined-row
      prefix
      %-  ~(put by (~(put by *(map qualified-table:ast (map @tas @))) a-qual data.i.ga))
      [b-qual data.i.b-rows]
  %=  $
    out    [jr out]
    cnt    +(cnt)
    b-rows  t.b-rows
  ==
::
++  check-noncontig
  ::  verify non-contiguous key column pairs match
  |=  [a-key=(list @) b-key=(list @) pairs=(list [@ud @ud])]
  ^-  ?
  ?~  pairs  %.y
  ?.  =((snag -.i.pairs a-key) (snag +.i.pairs b-key))
    %.n
  $(pairs t.pairs)
::
++  check-nonkey-cols
  ::  verify non-key column values match between rows
  |=  [a=data-row b=data-row cols=(list @tas)]
  ^-  ?
  ?~  cols  %.y
  =/  a-val  (get-col-from-row i.cols a)
  =/  b-val  (get-col-from-row i.cols b)
  ?~  a-val  %.n
  ?~  b-val  %.n
  ?.  =(u.a-val u.b-val)  %.n
  $(cols t.cols)
::
++  get-schema
    |=  [sys=((mop @da schema) gth) time=@da]
    ^-  schema
    =/  time-key  (add time 1)
    ~|  "schema not available for {<time>}"
    ->:(pop:schema-key (lot:schema-key sys `time-key ~))
++  get-view-cache
  |=  [key=ns-rel-key q=((mop ns-rel-key cache) ns-rel-comp)]
  ^-  cache
  =/  vw  (tab:view-cache-key q `[ns.key rel.key `@da`(add `@`time.key 1)] 1)
  ?~  vw
    ~|("view {<ns.key>}.{<rel.key>} does not exist from time {<time.key>}" !!)
  ->.vw
::
++  put-view-cache
  |=  [db=database value=cache key=ns-rel-key]
  ^-  database
  =/  gate  put:((on ns-rel-key cache) ns-rel-comp)
  db(view-cache (gate view-cache.db [key value]))
::
++  key-atom
  |=  a=[p=@tas q=(map @tas @)]
  ^-  @
  ~|  "key atom {<p.a>} not supported"
  (~(got by q.a) p.a)
--
