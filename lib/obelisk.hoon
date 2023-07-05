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
  |=  [state-dbs=databases =bowl:gall cmds=(list command:ast)]
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
      %=  $
        dbs   (drop-tbl dbs bowl -.cmds)
        cmds  +.cmds
        results  ['success' results]
      ==
    %drop-view
      !!
    %grant
      !!
    %revoke
      !!
    %transform
      =/  a  `[databases @ud @t]`(do-transform dbs bowl -.cmds)
      %=  $
        dbs   -.a
        cmds  +.cmds
        results  [[%transform-result +<.a +>.a] results]  :: to do, gets more complex w/ other transforms
      ==
    %truncate-table
      !!
  ==
++  do-transform
  |=  [dbs=databases =bowl:gall =transform:ast]
  ^-  [databases @ud @t]

  =/  ctes=(list cte)  ctes.transform  :: To Do - map CTEs
  =/  a  (do-set-functions dbs bowl set-functions.transform)
::  ~&  >  a
  !!

++  do-set-functions
  |=  [dbs=databases =bowl:gall =(tree set-function:ast)]

::  =/  rtree  ^+((~(rdc of tree) foo) tree)
::  =/  rtree  `(tree set-function:ast)`(~(rdc of tree) foo)
::  =/  rtree=(tree set-function:ast)  (~(rdc of tree) foo)
::  ?~  rtree  !!  :: fuse loop

  =/  rtree  (~(rdc of tree) rdc-set-func)

  ?-  -<.rtree
    %delete
      !!
    %insert
      =/  ins=insert:ast  -.rtree
      ~&  >  ins
      !!
    %update
      !!
    %query
      !!
    %merge
      !!
    == 
  ++  rdc-set-func
    |=  =(tree set-function)
    ?~  tree  ~
    ::  template
    ?~  l.tree
      ?~  r.tree  [n.tree ~ ~]
      [n.r.tree ~ ~]
    ?~  r.tree  [n.l.tree ~ ~]
    [n.r.tree ~ ~]
++  of                              ::  tree engine
  =|  a=(tree)                      
  |@
  ++  rep                           ::  reduce to product
    |*  b=_=>(~ |=([* *] +<+))
    |-
    ?~  a  +<+.b
    $(a r.a, +<+.b $(a l.a, +<+.b (b n.a +<+.b)))
  ++  rdc                           ::  reduce tree
    |*  b=gate
    |-
    ?:  ?=([* ~ ~] a)              a
    ?:  ?=([* [* ~ ~] [* ~ ~]] a)  $(a (b a))
    ?:  ?=([* ~ [* ~ ~]] a)        $(a (b a))
    ?:  ?=([* [* ~ ~] ~] a)        $(a (b a))
    ?:  ?=([* * ~] a)              $(a [n=n.a l=$(a l.a) r=~])
    ?:  ?=([* ~ *] a)              $(a [n=n.a l=~ r=$(a r.a)])
    ?:  ?=([* * *] a)              $(a [n=n.a l=$(a l.a) r=$(a r.a)])
    ~
  --
++  create-ns
  |=  [dbs=databases =bowl:gall =create-namespace]
  ^-  databases
  ?.  =(our.bowl src.bowl)  ~|("namespace must be created by local agent" !!)
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
  =/  internals=db-internals  -.sys.dbrow
  ?.  (~(has by namespaces.internals) namespace.table.create-table)
    ~|("namespace {<namespaces.internals>} does not exist" !!)
  =/  col-set  (name-set (silt columns.create-table))
  ?.  =((lent columns.create-table) ~(wyt in col-set))
    ~|("dulicate column names {<columns.create-table>}" !!)
  =/  key-col-set  (name-set (silt pri-indx.create-table))
  =/  key-count  ~(wyt in key-col-set)
  ?.  =((lent pri-indx.create-table) key-count)
    ~|("dulicate column names in key {<columns.create-table>}" !!)
  ?.  =(key-count ~(wyt in (~(int in col-set) key-col-set)))
    ~|("key column not in column definitions {<pri-indx.create-table>}" !!)
  =/  tables  
    ~|  "{<name.table.create-table>} exists in {<namespace.table.create-table>}"
    %:  map-insert
        tables.internals
        [namespace.table.create-table name.table.create-table]
        %:  table
            %table
            %:  index
                %index
                %.y
                clustered.create-table
                pri-indx.create-table
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
++  drop-tbl
  |=  [dbs=databases =bowl:gall =drop-table]
  ^-  databases
  ?.  =(our.bowl src.bowl)  ~|("table must be dropd by local agent" !!)
  =/  dbrow  ~|("database {<database.table.drop-table>} does not exist" (~(got by dbs) database.table.drop-table))
  =/  internals=db-internals  -.sys.dbrow
  ?.  (~(has by namespaces.internals) namespace.table.drop-table)
    ~|("namespace {<namespaces.internals>} does not exist" !!)
  =/  tables  
    ~|  "{<name.table.drop-table>} does not exists in {<namespace.table.drop-table>}"
    %+  map-delete
        tables.internals
        [namespace.table.drop-table name.table.drop-table]
  =.  -.sys.dbrow  %:  db-internals
                       %db-internals
                       %agent
                       now.bowl
                       namespaces.internals
                       tables
                       ==
  (~(put by dbs) database.table.drop-table dbrow)  :: prefer upd
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
++  name-set
  |*  a=(set)
  ^-  (set @tas)
  (~(run in a) |=(b=* ?@(b !! ?@(+<.b +<.b !!))))
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
++  map-delete
  |*  [m=(map) key=*]
  ^+  m
  ?:  (~(has by m) key)  (~(del by m) key)
  ~|("key does not exist for deletion: {<key>}" !!)
--
