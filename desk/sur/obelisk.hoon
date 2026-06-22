/-  *obelisk-ast, *server-state-1
/+  *mip
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
::
+$  set-table
  $+  set-table
  $:  %set-table
    join=(unit join-type)
    relation=(unit qualified-table)
    schema-tmsp=(unit @da)
    data-tmsp=(unit @da)
    columns=(list column)
    =predicate
    rowcount=@
    =map-meta
    pri-indx=(unit index)
    ordered=?
    pri-indexed=(tree [(list @) (map @tas @)])
    indexed-rows=(list indexed-row)
    joined-rows=(list joined-row)
    ==
::
+$  column-meta
  $+  column-meta
  $:  =qualified-column
      type=@ta
      addr=@
      ==
+$  qualified-map-meta
  $+  qualified-map-meta
  $:  %qualified-map-meta
    (mip qualifier @tas typ-addr)
    ==
+$  unqualified-map-meta
  $+  unqualified-map-meta
  $:  %unqualified-map-meta
    (map @tas typ-addr)
    ==
+$  map-meta  $%(qualified-map-meta unqualified-map-meta)
::
+$  qualifier-lookup  (map @tas (list qualified-table))
::
+$  qualifier  $%(qualified-table cte-name)
::
+$  joined-row
  $+  joined-row
  $:  %joined-row
    key=(list @)
    data=(mip qualified-table @tas @)
    ==
+$  data-row  $%(joined-row indexed-row)
::
+$  join-return
  $+  join-return
  $:  %join-return
    =server
    set-tables=(list set-table)
    =map-meta
    column-metas=(list column-meta)
    ==
::
+$  joined-relat
  $+  joined-relat
  $:  %joined-relat
    join=(unit join-type)
    =relation-id
    as-of=(unit as-of)
    =predicate
    ==
::
+$  full-relation
  $+  full-relation
  $:  %full-relation
    =qualifier
    set-tables=(list set-table)
    map-meta=qualified-map-meta
    column-metas=(list column-meta)
    ==
::
+$  named-ctes  (map @tas full-relation)
::
+$  resolved-scalar  $%  [%fn type=@ta f=$-(data-row dime)]
                         dime
                         ==
::
+$  resolved-scalars  (map @tas resolved-scalar)
::
::  template for selected column from qualified-column objects
+$  templ-cell
  $+  templ-cell
  $:  %templ-cell
    column=(unit qualified-column)
    scalar=(unit resolved-scalar)
    addr=@
    vc=vector-cell
    ==
::
+$  seed  @uvJ
::
::  common metadata for DELETE, INSERT, UPSERT, UPDATE
+$  txn-meta
  $+  txn-meta
  $:  %txn-meta
    db=database
    tbl-key=[@tas @tas]
    nxt-data=data
    =table
    =file
    source-content-time=@da
    ==
::
+$  table-return
  $+  table-return
  $:  [@da ? @ud]
      changed-schemas=(map @tas @da)
      changed-data=(map @tas @da)
      state=server
      ==
::
+$  constrained-value-edit
  $%  [%add parent-key=(list @) child-pk=(list @)]
      [%remove parent-key=(list @) child-pk=(list @)]
      $:  %move
          old-parent-key=(list @)
          new-parent-key=(list @)
          old-child-pk=(list @)
          new-child-pk=(list @)
          ==
      ==
+$  constrained-value-row-tuples
  $:  old-parent-key=(list @)
      new-parent-key=(list @)
      old-child-pk=(list @)
      new-child-pk=(list @)
      ==
--
