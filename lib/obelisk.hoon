/-  ast, *obelisk
|%
++  new-database
  |=  [dbs=databases now=@da c=command:ast]
  ^-  databases
  ?:  =(+.c %sys)  ~|("database name cannot be 'sys'" !!)
  ?>  ?=(create-database:ast c)
  =/  ns=namespaces
    %:  my 
        :~  [%sys (ns-row %ns-row %sys %agent now)]
            [%dbo (ns-row %ns-row %dbo %agent now)]
            ==
        ==
  %:  %~  put  by  dbs
      [+.c (db-row %db-row +.c %agent now (db-internals %db-internals ns))]
      ==
++  process-cmds
  |=  [dbs=databases =bowl:gall default-database=@tas cmds=(list command:ast)]
  ^-  databases
  |-  ?~  cmds  dbs
  ?-  -<.cmds
    %alter-index
      !!
    %alter-namespace
      !!
    %alter-table
      !!
    %create-database
      !!
    %create-index
      !!
    %create-namespace
      %=  $
        dbs   (create-ns dbs bowl default-database -.cmds)
        cmds  +.cmds
      ==
   %create-table
     !!
    %create-view
      !!
    %drop-database
      !!
    %drop-index
      !!
    %drop-namespace
      !!
    %drop-table
      !!
    %drop-view
      !!
    %grant
      !!
    %revoke
      !!
    %transform
      !!
    %truncate-table
      !!
  ==
++  create-ns
  |=  [dbs=databases =bowl:gall default-database=@tas =create-namespace]
  ^-  databases


  dbs
--
