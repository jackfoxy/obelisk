/-  *ast
^?
|%
+$  databases  (map @tas database)
+$  database
  $:  %database
      name=@tas
      created-provenance=path
      created-tmsp=@da
      sys=((mop @da schema) gth)     ::(tree [@da schema])
      content=(tree [@da data])
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
      length=@ud
      column-lookup=(map @tas [@tas @ud])   :: name [type index]
      key=(list [@tas ?])
      pri-idx=(tree [(list @) (map @tas @)])
      data=(list (map @tas @))
      ::    =indices
  ==
+$  data-obj-key
  $:  ns=@tas
      obj=@tas
      time=@da
  ==
+$  namespaces  (map @tas @da)
+$  tables  (map [@tas @tas] table)
+$  table
  $+  table
  $:  %table
      provenance=path
      tmsp=@da
      pri-indx=index 
      columns=(list column)             ::  canonical column list
      indices=(list index)
  ==
+$  views  ((mop data-obj-key view) ns-obj-comp)
+$  view
  $+  view
  $:  %view
      provenance=path
      tmsp=@da
      is-dirty=?
      is-tombstoned=?
      =transform
      columns=(list column)             ::  canonical column list
      ordering=(list column-order)
      content=(list (list @))
  ==
+$  index
  $:  %index
      unique=?
      clustered=?
      columns=(list ordered-column)
  ==
+$  cell  [p=@tas q=dime]
+$  row   [%row (list cell)]
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
      [%result-ud msg=@t count=@ud]
      [%result-da msg=@t date=@da]
      [%result-set (list row)]
      ==
+$  table-return
  $:  [@da ? @ud]
      (map @tas [(unit schema) (unit data)])
      (map @tas [(unit schema) (unit data)])
  ==
::
::  view and table comparer
++  ns-obj-comp 
  |=  [p=data-obj-key q=data-obj-key]
  ^-  ?
  ?.  =(ns.p ns.q)  (gth ns.p ns.q)
  ?.  =(obj.p obj.q)  (gth obj.p obj.q)
  (gth time.p time.q)
::
::  view key
++  view-key  ((on data-obj-key view) ns-obj-comp)
-- 
 