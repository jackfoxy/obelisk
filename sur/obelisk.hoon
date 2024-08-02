/-  *ast
^?
|%
+$  databases  (map @tas database)
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
  :: indices  ::  indices other than primary key
      =views
  :: permissions
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
      clustered=?
      rowcount=@
      pri-idx=(tree [(list @) (map @tas @)])
      rows=(list (map @tas @))
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
      key=(list [@tas ?])
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
      =transform
      =column-lookup
      columns=(list column)      ::  canonical column list
      ordering=(list column-order)
      :: indices  -  to do
  ==
+$  column-lookup  (map @tas [aura @])  :: name [type index]
+$  index
  $:  %index
      unique=?
      clustered=?
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
      [%tape-create-db urql=tape]
      [%cmd-create-db cmd=create-database]
  ==
+$  cmd-result  [%results (list result)]
+$  result
  $%  [%message msg=@t]
      [%vector-count count=@ud]
      [%server-time date=@da]
      [%schema-time date=@da]
      [%data-time date=@da]
      [%result-set (list vector)]
      ==
::
::  helper types
::
+$  table-return
  $:  [@da ? @ud]
      changed-schemas=(map @tas @da)
      changed-data=(map @tas @da)
      state=databases
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
