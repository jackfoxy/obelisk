/-  *ast
|%
+$  action
  $%  [%push target=@p value=@]
      [%pop target=@p]
      [%tape urql=(list @t) current-database=@tas]
      [%commands current-database=@tas cmds=(list command)]
     :: [%create-database =(list command:ast)]   
  ==
--  