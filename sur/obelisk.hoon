/-  *ast
^?
|%
+$  databases  (map @tas database)
+$  database
  $:  %database
      name=@tas
      created-provenance=path
      created-tmsp=@da
      sys=(tree [@da schema])
      content=(tree [@da data])
  ==
+$  schema
  $:  %schema
      provenance=path
      tmsp=@da
      =namespaces
      =tables
  :: indices  ::  indices other than primary key
  :: views
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
+$  namespaces  (map @tas @da)
+$  tables  (map [@tas @tas] table)
+$  table
  $:  %table
      provenance=path
      tmsp=@da
      pri-indx=index 
      columns=(list column)             ::  canonical column list
      indices=(list index)
  ==
+$  index
  $:  %index
      unique=?
      clustered=?
      columns=(list ordered-column)
  ==
  :: $| validator mold for adding rows with FKs
::
+$  action
  $%  [%tape default-database=@tas urql=tape]
      [%commands cmds=(list command)]
      [%tape-create-db urql=tape]
      [%cmd-create-db cmd=create-database]   
  ==
+$  msg  @t
+$  cmd-result
  $%  msg
      [%result-ud msg=@t count=@ud]
      [%result-da msg=@t date=@da]
      $:  %result-set
          qualifier=@ta
          columns=(list [@tas @tas])
          data=(list (list @))
      ==
  ==
+$  result  [%results (list cmd-result)]
+$  table-return
  $:  [@da ?]
      (map @tas [(unit schema) (unit data)])
      (map @tas [(unit schema) (unit data)])
  ==
-- 
 