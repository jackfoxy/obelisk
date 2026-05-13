/-  *ast
^?
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
+$  server  (map @tas database)
+$  database
  $:  %database
    name=@tas
    created-provenance=path
    created-tmsp=@da
    sys=((mop @da schema) gth)
    content=((mop @da data) gth)
    =view-cache
    event-log=(list sys-log-event)
    ==
+$  view-cache  ((mop ns-rel-key cache) ns-rel-comp)
+$  cache
  $:  %cache
    tmsp=@da
    content=(unit cache-content)
    ==
+$  cache-content
  $:  rowcount=@
      rows=(list (map @tas @))
      ==
+$  schema
  $:  %schema
    provenance=path
    tmsp=@da
    =namespaces
    =tables
    =views
  :: permissions   :: maybe at server or database level?
    ==
+$  data
  $:  %data
    ship=@p
    provenance=path
    tmsp=@da
    files=(map [@tas @tas] file)
    ==
::  Foreign-key metadata invariant
::
::  `foreign-constraints` on `file` is the authoritative incoming
::  constraint/dependency structure. It records declared foreign-key
::  constraints where this table is the referenced/parent table.
::
::  Entries must exist for declared constraints even when no child rows
::  currently reference this table. In that case the constrained-values map
::  is empty.
::
::  `constrained-values` is a maintained reverse index for one complete
::  foreign-key constraint:
::
::    map key:    referenced parent primary-key value tuple
::                == constrained child foreign-key value tuple
::
::    set value:  constrained child row primary-key value tuples currently
::                referencing that parent key
::
::  For child INSERT, each outbound FK from the inserted table adds the
::  inserted row's primary-key tuple to the parent file's matching
::  foreign-constraint.constrained-values at the inserted row's FK value tuple.
::
::  For child UPDATE, each affected outbound FK must move or rewrite the child
::  row reference atomically:
::
::    * if FK source columns changed, remove the old child primary-key tuple
::      from the old FK value tuple and add the new child primary-key tuple at
::      the new FK value tuple.
::
::    * if only child primary-key columns changed, replace the old child
::      primary-key tuple with the new child primary-key tuple at the same FK
::      value tuple.
::
::    * if both changed, remove old PK from old FK tuple and add new PK to new
::      FK tuple.
::
::  For child DELETE, each outbound FK removes the deleted row's primary-key
::  tuple from the parent file's matching constrained-values entry at the
::  deleted row's FK value tuple. Empty child-key sets should be removed from
::  constrained-values.
::
::  Self-referential FKs update the same file as both child and parent, but the
::  same invariant applies.
::
::  `outbound-fk-index` on `table` is a derived child-side lookup index. It
::  exists to find outgoing foreign keys involving a source column of this
::  table. It is not the canonical constraint definition and intentionally
::  does not store ON DELETE / ON UPDATE actions.
::
::  Invariant: every `outbound-fk-index` entry must correspond to exactly one
::  `foreign-constraints` entry on the referenced file, and every canonical
::  `foreign-constraints` entry must be represented in `outbound-fk-index` for
::  each constrained source column included in that foreign key. Schema/data
::  mutation code must update both sides atomically at the same effective
::  timestamp.
+$  table
  $+  table
  $:  %table
    provenance=path
    tmsp=@da
    =column-lookup
    typ-addr-lookup=(map @tas typ-addr)
    pri-indx=index
    columns=(list column)      ::  canonical column list
    indices=(list index)
    ::  outbound-fk-index
    ::    map @tas  := column of this table
    ::        list  :+  [@tas @tas]  := reference namespace table
    ::                  (list @tas)  := key column names in this table
    ::                  (list @tas)  := primary key column name in reference table
    outbound-fk-index=outbound-fk-index
    ==
+$  key-constraint  ?(%cascade %restrict %set-default)
+$  constraints
  $:  %constraints
      on-delete=key-constraint
      on-update=key-constraint
      ==
+$  column-lookup  (map @tas [aura @])
+$  typ-addr
  $:  type=@ta
      addr=@
      ==
+$  file
  $:  %file
    ship=@p
    provenance=path
    tmsp=@da
    rowcount=@
    pri-idx=(tree [(list @) (map @tas @)])  ::generic, reify as mop
    indexed-rows=(list indexed-row)
    ::  foreign-constraints, tables constrained by this table's primary key
    ::    list
    ::      :-  [@tas @tas]  := constrained namespace table
    ::          :^  constraints
    ::              (list @tas)    := constrained table's primary key columns
    ::              (list @tas)    := constrained table's constrained columns
    ::              map (list @)   := constrained values
    ::                  (set (list @))   := constrained table's key values thus constrained
    foreign-constraints=(list foreign-constraint)
    ::    =indices
    ==
+$  outbound-fk-entry
  $:  reference-table=[@tas @tas]
      constrained-columns=(list @tas)
      reference-columns=(list @tas)
      ==
+$  outbound-fk-index  (map @tas (list outbound-fk-entry))
+$  constrained-values  (map (list @) (set (list @)))
+$  foreign-constraint
  $:  constrained-table=[@tas @tas]
      actions=constraints
      constrained-primary-key=(list @tas)
      constrained-columns=(list @tas)
      constrained-values=constrained-values
      ==
+$  indexed-row
  $:  %indexed-row
    key=(list @)
    data=(map @tas @)
    ==
+$  qualified-addrs  [%qualified-addrs (map [qualified-table @tas] @)]
+$  file-ord   @ud              :: ordinal position in indexed-row sorted file
::
+$  ns-rel-key
  $:  ns=@tas
      rel=@tas
      time=@da
      ==
+$  namespaces  (map @tas @da)
+$  tables  (map [@tas @tas] table)
+$  views  ((mop ns-rel-key view) ns-rel-comp)
+$  view
  $+  view
  $:  %view
    provenance=path
    tmsp=@da
    =crud-txn
    =column-lookup
    typ-addr-lookup=(map @tas typ-addr)
    columns=(list column)      ::  canonical column list
    ordering=(list column-order)
    indices=(list index)
    ==
::
+$  sys-log-event
  $:  %sys-log-event
    tmsp=@da
    provenance=path
    action=@tas
    component=@tas
    database=@tas
    namespace=(unit @tas)
    relation=(unit @tas)
    target-database=(unit @tas)
    target-namespace=(unit @tas)
    target-relation=(unit @tas)
    message=(unit @t)
    ==
::
+$  index
  $:  %index
    unique=?
    key=(list key-column)
    ==
+$  key-column
  $:  %key-column
    name=@tas
    =aura
    ascending=?
    ==
+$  column-order  [aor=? ascending=? offset=@ud]
::
::    +ns-rel-comp: [ns-rel-key ns-rel-key] -> ?
::
::  view and table comparer
++  ns-rel-comp
  |=  [p=ns-rel-key q=ns-rel-key]
  ^-  ?
  ?.  =(ns.p ns.q)  (gth ns.p ns.q)
  ?.  =(rel.p rel.q)  (gth rel.p rel.q)
  (gth time.p time.q)
--
