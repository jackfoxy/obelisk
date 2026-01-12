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
+$  table
  $+  table
  $:  %table
    provenance=path
    tmsp=@da
    =column-lookup
    type-lookup=(map @tas @ta)
    pri-indx=index
    columns=(list column)      ::  canonical column list
    indices=(list index)      :: to do: indices indexed by (list column)
    ==
+$  column-lookup  (map @tas [aura @])  :: name [type index]
+$  file
  $:  %file
    ship=@p
    provenance=path
    tmsp=@da
    rowcount=@
    pri-idx=(tree [(list @) (map @tas @)])  ::generic, reify as mop
    indexed-rows=(list indexed-row)
    ::    =indices
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
    =selection
    =column-lookup
    type-lookup=(map @tas @ta)
    columns=(list column)      ::  canonical column list
    :: to do: replace ordering with index (requires non-unique mop type)
    ordering=(list column-order)
    :: indices
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