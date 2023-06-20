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
  %:  map-insert  dbs  +.c  %:  db-row 
                                %db-row 
                                +.c 
                                %agent 
                                now 
                                ~[(db-internals %db-internals %agent now ns)]
                                ==
      ==
++  process-cmds
  |=  [state-dbs=databases =bowl:gall default-db=@tas cmds=(list command:ast)]
  ^-  databases
  =/  dbs  state-dbs
  |-  
  ?~  cmds  (update-state [state-dbs dbs])
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
  =/  dbrow  (~(got by dbs) database-name.create-namespace)
  =/  internals=db-internals  -.sys.dbrow
  =/  namespaces  ~|  "namespace {<name.create-namespace>} already exists"
                      %:  map-insert 
                      namespaces.internals 
                      name.create-namespace 
                      name.create-namespace
                      ==
  =.  -.sys.dbrow  (db-internals %db-internals %agent now.bowl namespaces)
  (~(gas by dbs) ~[[database-name.create-namespace dbrow]])
++  update-state
  |=  [current=databases next=databases]
  ^-  databases
  =/  a  (fuse [~(tap by current) ~(tap by next)])
  |-
  ?~  a  current
  :: old db-internals tmsp = new tmsp
  ?:  =(<-<+>+>+<+>-.a> <->+>+>+<+>-.a>)  $(a +.a)
  =/  dbrow=db-row  (~(got by current) -<-.a)
  =.  sys.dbrow     [`db-internals`->+>+>+<.a sys.dbrow]
  %=  $
    a        +.a
    current  (~(put by current) -<-.a dbrow)
  ==
++  fuse                        :: credit to ~paldev
  |*  [a=(list) b=(list)]       :: [(list a) (list b)] -> (list [a b])
  ^-  (list [_?>(?=(^ a) i.a) _?>(?=(^ b) i.b)])
  ?~  a  ~
  ?~  b  ~
  :-  [i.a i.b]
  $(a t.a, b t.b)
++  map-insert
  |*  [m=(map) key=* value=*]
  ^+  m
  ?:  (~(has by m) key)  ~|("cannot add duplicate key: {<key>}" !!)
  (~(put by m) key value)
--
