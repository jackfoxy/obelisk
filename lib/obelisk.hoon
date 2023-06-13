/-  ast, *obelisk
|%
++  new-database
  |=  [dbs=databases now=@da c=command:ast]
  ^-  databases
  ?:  =(+.c %sys)  ~|("database name cannot be 'sys'" !!)
  ?>  ?=(create-database:ast c)
  =/  ns=namespaces
    %:  my 
        :~  [%sys %sys]
            [%dbo %dbo]
            ==
        ==
  %:  %~  put  by  dbs
      :-  +.c  %:  db-row 
                   %db-row 
                   +.c 
                   %agent 
                   now 
                   ~[(db-internals %db-internals %agent now ns)]
                   ==
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
        dbs   (create-ns dbs bowl -.cmds)
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
  |=  [dbs=databases =bowl:gall =create-namespace]
  ^-  databases
  ?.  =(our.bowl src.bowl)  ~|("namespace must be created by local agent" !!)
  ?:  =(name.create-namespace 'sys')  ~|("cannot add namespace 'sys'" !!)
  =/  dbrow  (~(got by dbs) database-name.create-namespace)
  =/  internals=db-internals  -.sys.dbrow
  =/  namespaces  %:  ~(put by namespaces.internals) 
                      name.create-namespace 
                      name.create-namespace
                      ==
  =.  sys.dbrow  :-  (db-internals %db-internals %agent now.bowl namespaces)
                     sys.dbrow
  (~(gas by dbs) ~[[database-name.create-namespace dbrow]])
--
