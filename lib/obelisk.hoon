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
  =/  tbs=tables  ~
  %:  map-insert  dbs  +.c  %:  db-row 
                                %db-row 
                                +.c 
                                %agent 
                                now 
                                ~[(db-internals %db-internals %agent now ns tbs)]
                                ==
      ==
++  process-cmds
  |=  [state-dbs=databases =bowl:gall default-db=@tas cmds=(list command:ast)]
  ^-  [(list cmd-result) databases]
  =/  dbs  state-dbs
  =/  results=(list cmd-result)  ~
  |-  
  ?~  cmds  [(flop results) (update-state [state-dbs dbs])]
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
        results  ['success' results]
      ==
    %create-table
     %=  $
        dbs   (create-tbl dbs bowl -.cmds)
        cmds  +.cmds
        results  ['success' results]
      ==
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

  :: to do fail on db does not exist
  =/  dbrow  ~|("database {<database-name.create-namespace>} does not exist" (~(got by dbs) database-name.create-namespace))
  =/  internals=db-internals  -.sys.dbrow
  =/  namespaces  ~|  "namespace {<name.create-namespace>} already exists"
                      %:  map-insert 
                          namespaces.internals 
                          name.create-namespace 
                          name.create-namespace
                      ==
  =.  -.sys.dbrow  %:  db-internals 
                       %db-internals 
                       %agent 
                       now.bowl 
                       namespaces 
                       tables.internals
                       ==
  (~(put by dbs) database-name.create-namespace dbrow)  :: prefer upd

++  create-tbl
  |=  [dbs=databases =bowl:gall =create-table]
  ^-  databases
  ?.  =(our.bowl src.bowl)  ~|("table must be created by local agent" !!)
  =/  dbrow  ~|("database {<database.table.create-table>} does not exist" (~(got by dbs) database.table.create-table))

  :: to do ns must exist
  =/  internals=db-internals  -.sys.dbrow
  =/  tables  
        ~|  
        "{<name.table.create-table>} exists in {<namespace.table.create-table>}"
        %:  map-insert 
            tables.internals 
            [namespace.table.create-table name.table.create-table] 
            %:  table 
                %table 
                %:  index 
                    %index 
                    %.y 
                    clustered.pri-indx.create-table 
                    columns.pri-indx.create-table
                ==
                columns.create-table 
                ~
            ==
        ==
  =.  -.sys.dbrow  %:  db-internals 
                       %db-internals 
                       %agent 
                       now.bowl 
                       namespaces.internals 
                       tables
                       ==
  (~(put by dbs) database.table.create-table dbrow)  :: prefer upd


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
