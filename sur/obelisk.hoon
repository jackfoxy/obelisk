/-  *ast
|%
+$  databases  (map @tas db-row)
+$  db-row
  $:  %db-row
      name=@tas
      created-by-agent=@tas
      created-tmsp=@da
      =db-internals
  ==
+$  db-internals
  $:  %db-internals
      =namespaces
  :: tables
  :: views
  :: indices
  :: permissions
  ==
+$  namespaces  (map @tas ns-row)
+$  ns-row
  $:  %ns-row
      name=@tas
      created-by-agent=@tas
      created-tmsp=@da
  ==

  :: $| validator mold for adding rows with FKs
::
+$  action
  $%  [%tape default-database=@tas urql=tape]
      [%commands default-database=@tas cmds=(list command)]
      [%tape-create-db urql=tape]
      [%cmd-create-db cmd=create-database]   
  ==
+$  response
  $%  [%result msg=tape]
  ==
--  