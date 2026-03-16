/-  *ast, *server-state
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
::  $action
::    [%tape @tas tape]          - prints result to dodjo
::    [%tape2 @tas tape]         - suppresses printing result to dodjo
::    [%commands (list command)] - prints result to dodjo
::    [%test @tas tape]          - supports expect-fail-message in unit tests
::    [%parse tape]              - returns (list command)
::  
+$  action
  $%
    [%tape default-database=@tas urql=tape]
    [%tape2 default-database=@tas urql=tape]
    [%commands cmds=(list command)]
    [%test default-database=@tas urql=tape]
    [%parse urql=tape]
    ==
::
+$  db-cmd
  $?
    %create-database
    %drop-database
    %create-namespace
    %alter-namespace
    %drop-namespace
    %create-table
    %alter-table
    %drop-table
    %truncate-table
    %insert
    %update
    %delete
    ==
::
+$  cmd-result  [%results (list result)]
+$  result
  $%
    [%message msg=@t]
    [%vector-count count=@ud]
    [%server-time date=@da]
    [%security-time date=@da]
    [%schema-time date=@da]
    [%data-time date=@da]
    [%result-set (list vector)]
    ==
::
+$  set-table
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
    pri-indexed=(tree [(list @) (map @tas @)])
    indexed-rows=(list indexed-row)
    joined-rows=(list joined-row)
    ==
::
+$  column-meta
  $:  =qualified-column
      type=@ta
      addr=@
      ==
+$  qualified-map-meta
  $:  %qualified-map-meta
    (mip qualifier @tas typ-addr)
    ==
+$  unqualified-map-meta
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
  $:  %joined-row
    key=(list @)
    data=(mip qualified-table @tas @)
    ==
+$  data-row  $%(joined-row indexed-row)
::
+$  join-return
  $:  %join-return
    =server
    set-tables=(list set-table)
    =map-meta
    column-metas=(list column-meta)    ::to do: rename
    ==
::
+$  joined-relat
  $:  %joined-relat
    join=(unit join-type)
    =relation
    as-of=(unit as-of)
    =predicate
    ==
::
+$  full-relation
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
  $:  %templ-cell
    column=(unit qualified-column)
    addr=@
    vc=vector-cell
    ==
::
+$  vector-cell  [p=@tas q=dime]
+$  vector
  $:  %vector
    (lest vector-cell)
    ==
::
::  common metadata for DELETE, INSERT, UPDATE
+$  txn-meta
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
  $:  [@da ? @ud]
      changed-schemas=(map @tas @da)
      changed-data=(map @tas @da)
      state=server
      ==
--
