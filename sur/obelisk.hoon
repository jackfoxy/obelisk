/-  *ast
|%
+$  action
  $%  [%push target=@p value=@]
      [%pop target=@p]
      [%tape current-database=@tas urql=tape]
      [%commands current-database=@tas cmds=(list command)]
      [%tape-create-db urql=tape]
      [%cmd-create-db cmd=create-database]   
  ==
+$  response
  $%  [%result values=(list @)]
  ==
--  