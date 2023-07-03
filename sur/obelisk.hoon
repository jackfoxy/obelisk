/-  *ast
|%
+$  databases  (map @tas db-row)
+$  db-row
  $:  %db-row
      name=@tas
      created-by-agent=@tas
      created-tmsp=@da
      sys=(list db-internals)
  ==
+$  db-internals
  $:  %db-internals
      agent=@tas
      tmsp=@da
      =namespaces
      =tables
  :: indices
  :: views
  :: permissions
  ==
+$  namespaces  (map @tas @tas)
+$  tables  (map [@tas @tas] table)
+$  table
  $:  %table 
      pri-indx=index 
      columns=(list column) 
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
      [%transform-result msg-count=@ud msg=@t]
  ==
+$  result  [%results (list cmd-result)]
--  