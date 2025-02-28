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
+$  view-cache  ((mop data-obj-key cache) ns-obj-comp)
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
  :: indices  ::  indices other than primary key, indexed by? 
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
+$  file
  $:  %file
      ship=@p
      provenance=path
      tmsp=@da
      rowcount=@
      pri-idx=(tree [(list @) (map @tas @)])
      indexed-rows=(list [(list @) (map @tas @)])
      ::    =indices
  ==
+$  data-obj-key
  $:  ns=@tas
      obj=@tas
      time=@da
  ==
+$  data-obj
  $:  %data-obj
      sys-time=@da
      data-time=@da
      columns=(list column)
      rowcount=@
      rows=(list vector)
  ==
+$  namespaces  (map @tas @da)
+$  tables  (map [@tas @tas] table)
+$  table
  $+  table
  $:  %table
      provenance=path
      tmsp=@da
      =column-lookup
      key=(list [@ta ?])
      pri-indx=index
      columns=(list column)      ::  canonical column list
      indices=(list index)      :: to do: indices indexed by (list column)
  ==
+$  views  ((mop data-obj-key view) ns-obj-comp)
+$  view
  $+  view
  $:  %view
      provenance=path
      tmsp=@da
      =selection
      =column-lookup
      columns=(list column)      ::  canonical column list
      ordering=(list column-order)
      :: indices  -  to do
  ==
+$  column-lookup  (map @tas [aura @])  :: name [type index]
+$  index
  $:  %index
      unique=?
      columns=(list ordered-column)
  ==
+$  vector-cell  [p=@tas q=dime]
+$  vector
    $:  %vector
        (lest vector-cell)
    ==
+$  column-order  [aor=? ascending=? offset=@ud]
  :: $| validator mold for adding rows with FKs
::
+$  action
  $%  [%tape default-database=@tas urql=tape]
      [%commands cmds=(list command)]
      [%test default-database=@tas urql=tape]
  ==
+$  cmd-result  [%results (list result)]
+$  result
  $%  [%message msg=@t]
      [%vector-count count=@ud]
      [%server-time date=@da]
      [%security-time date=@da]
      [%schema-time date=@da]
      [%data-time date=@da]
      [%result-set (list vector)]
      ==
::
+$  from-obj
  $:  %from-obj
      object=qualified-object
      alias=(unit @t)
      schema-tmsp=@da
      data-tmsp=@da
      columns=(list column)
      qualified-columns=(list [qualified-column @ta])
      key=(list [@ta ?])
      pri-indx=(unit index)
      join=(unit join-type)
      predicate=(unit predicate)
      type-lookup=(map qualified-object (map @tas @ta))
      rowcount=@
      pri-indexed=(tree [(list @) (map @tas @)])
      indexed-rows=(list [(list @) (map @tas @)])
      joined-rows=(list joined-row)
  ==
::
+$  joined-row  (map qualified-object (map @tas @))
::
+$  relation
  $:
    %relation
    =table-set
    as-of=(unit as-of)
    join=(unit join-type)
    predicate=(unit predicate)
  ==
::
::  helper types
::
+$  table-return
  $:  [@da ? @ud]
      changed-schemas=(map @tas @da)
      changed-data=(map @tas @da)
      state=server
  ==
::
::    +ns-obj-comp: [data-obj-key data-obj-key] -> ?
::
::  view and table comparer
++  ns-obj-comp
  |=  [p=data-obj-key q=data-obj-key]
  ^-  ?
  ?.  =(ns.p ns.q)  (gth ns.p ns.q)
  ?.  =(obj.p obj.q)  (gth obj.p obj.q)
  (gth time.p time.q)
  
--
