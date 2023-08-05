/-  ast, *obelisk
|%
++  new-database
  |=  [dbs=databases =bowl:gall c=command:ast]
  ^-  [databases cmd-result]
  ?:  =(+.c %sys)  ~|("database name cannot be 'sys'" !!)
  ?>  ?=(create-database:ast c)
  =/  ns=namespaces
    %:  my 
        :~  [%sys now.bowl]
            [%dbo now.bowl]
            ==
        ==
  =/  tbs=tables  ~
  :-
  %:  map-insert  dbs  +.c  %:  db-row 
                                %db-row 
                                +.c 
                                %agent 
                                now.bowl 
                                ~[(internals %internals %agent now.bowl ns tbs)]
                                ~[(data %data src.bowl %agent now.bowl ~)]
                                ==
      ==
  `cmd-result`[%result-da 'system time' now.bowl]
++  process-cmds
  |=  [state-dbs=databases =bowl:gall cmds=(list command:ast)]
  ^-  [(list cmd-result) databases]
  =/  dbs  state-dbs
  =/  results=(list cmd-result)  ~
  |-  
  ?~  cmds  [[%results (flop results)] (update-state [state-dbs dbs])]
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
        dbs      (create-ns dbs bowl -.cmds)
        cmds     +.cmds
        results  [`cmd-result`[%result-da 'system time' now.bowl] results]
      ==
    %create-table
      %=  $
        dbs      (create-tbl dbs bowl -.cmds)
        cmds     +.cmds
        results  [`cmd-result`[%result-da 'system time' now.bowl] results]
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
        dbs      (drop-tbl dbs bowl -.cmds)
        cmds     +.cmds
        results  [`cmd-result`[%result-da 'system time' now.bowl] results]
      ==
    %drop-view
      !!
    %grant
      !!
    %revoke
      !!
    %transform
      =/  a  `[databases (list cmd-result)]`(do-transform dbs bowl -.cmds)
      %=  $
        dbs      -.a
        cmds     +.cmds
        results  (weld +.a results)
      ==
    %truncate-table
      !!
  ==
++  do-transform
  |=  [dbs=databases =bowl:gall =transform:ast]
  ^-  [databases (list cmd-result)]

  =/  ctes=(list cte:ast)  ctes.transform  :: To Do - map CTEs
  (do-set-functions dbs bowl set-functions.transform)
++  do-set-functions
  |=  [dbs=databases =bowl:gall =(tree set-function:ast)]

  ::  =/  rtree  ^+((~(rdc of tree) foo) tree)
  ::  =/  rtree  `(tree set-function:ast)`(~(rdc of tree) foo)
  ::  =/  rtree=(tree set-function:ast)  (~(rdc of tree) foo)
  ::  ?~  rtree  !!  :: fuse loop
  ^-  [databases (list cmd-result)] 
  =/  rtree  (~(rdc of tree) rdc-set-func)

  ?-  -<.rtree
    %delete
      !!
    %insert
      (do-insert dbs bowl -.rtree)
    %update
      !!
    %query
      [dbs (do-query dbs bowl -.rtree)]
  ::    ~&  >  "-.rtree: {<-.rtree>}"
  ::    ~&  >  "+.rtree: {<+.rtree>}"
  ::    ?>  ?=(query:ast -.rtree)
  ::    `query:ast`-.rtree
  ::    -.rtree

  ::    !!
    %merge
      !!
    == 
  ++  do-query
    |=  [dbs=databases =bowl:gall q=query:ast]
    ^-  (list cmd-result)
    ?~  from.q  !!
    =/  =from:ast  (need from.q)
    =/  =table-set:ast  object.from
    ?:  ?&  ?=(qualified-object:ast object.table-set)
            =(namespace.object.table-set 'sys')
        ==
      ~[(sys-views dbs bowl object.table-set)]
    !!
  ++  sys-views
    |=  [dbs=databases =bowl:gall q=qualified-object:ast]
    ^-  cmd-result
    ?:  =(%databases name.q)
      ?.  ?&(=(%sys database.q) =(%sys namespace.q))
        ~|("databases view only in database namespace 'sys.sys'" !!)
      =/  databases-order  ~[[%t %.y 0] [%da %.y 2] [%da %.y 5]]
      =/  dbes             (turn ~(val by dbs) sys-view-databases)
      :^  %result-set
          ~.sys.sys.databases
          :~  [%database %tas] 
              [%sys-agent %tas] 
              [%sys-tmsp %da] 
              [%data-ship %p] 
              [%data-agent %tas] 
              [%data-tmsp %da]
          ==
      (sort `(list (list @))`(zing dbes) ~(order order-row databases-order))
    =/  dbrow  
      ~|  "database {<database.q>} does not exist" 
      (~(got by dbs) database.q)
    =/  sys=internals  -.sys.dbrow
    =/  =tables        tables.sys
    =/  udata=data     -.user-data.dbrow
    ?+  name.q  !!
    %columns
      =/  columns-order  ~[[%t %.y 0] [%ud %.y 2]]
      =/  columns  (turn ~(tap by files.udata) ~(foo sys-view-columns tables))
      :^
      %result-set
      `@ta`(crip (weld (trip database.q) ".sys.columns"))
       :~  [%namespace %tas] 
           [%name %tas]  
           [%col-ordinal %ud]
           [%col-name %tas]
           [%col-type %tas]
           ==
      (sort `(list (list @))`(zing columns) ~(order order-row columns-order))
    ::
    %namespaces
      =/  ns-order    ~[[%t %.y 0]]
      =/  namespaces  (~(urn by namespaces.sys) |=([k=@tas v=@da] ~[k v]))
      :^
      %result-set
      `@ta`(crip (weld (trip database.q) ".sys.namespaces"))
      ~[[%namespace %tas] [%tmsp %da]]
      (sort `(list (list @))`~(val by namespaces) ~(order order-row ns-order))
    ::
    %tables
      =/  tables-order  ~[[%t %.y 0] [%t %.y 1] [%ud %.y 7] [%ud %.y 10]]
      =/  tbls  (turn ~(tap by files.udata) ~(foo sys-view-tables tables))
      :^
      %result-set
      `@ta`(crip (weld (trip database.q) ".sys.tables"))
       :~  [%namespace %tas] 
           [%name %tas] 
           [%ship %p] 
           [%agent %tas] 
           [%tmsp %da] 
           [%row-count %ud] 
           [%clustered %f] 
           [%key-ordinal %ud] 
           [%key %tas] 
           [%key-ascending %f] 
           [%col-ordinal %ud]
           [%col-name %tas]
           [%col-type %tas]
           ==
      (sort `(list (list @))`(zing tbls) ~(order order-row tables-order))
    ::
    %sys-logs
      :^
      %result-set
      `@ta`(crip (weld (trip database.q) ".sys.sys-logs"))
      ~[[%agent %tas] [%tmsp %da]]
      (turn sys.dbrow |=(a=internals ~[agent.a tmsp.a]))
    ::
    %data-logs
      :^
      %result-set
      `@ta`(crip (weld (trip database.q) ".sys.data-logs"))
      ~[[%ship %p] [%agent %tas] [%tmsp %da]]
      (turn user-data.dbrow |=(a=data ~[ship.a agent.a tmsp.a]))
    ==
  ++  sys-view-databases
    |=  a=db-row
    ^-  (list (list @))
    =/  sys=(list internals)  (flop sys.a)
    =/  udata=(list data)      (flop user-data.a)
    =/  rslt=(list (list @))  ~
    |-
    ?:  ?&(=(~ sys) =(~ udata))  (flop rslt)
    ?~  sys
      %=  $
      rslt  [~[name.a ->-.rslt ->+<.rslt ->-.udata ->+<.udata ->+>-.udata] rslt]
      udata  +.udata
      ==
    ?~  udata
      ?>  !=(~ rslt)
      %=  $
      rslt  
        [~[name.a ->-.sys ->+<.sys ->+>-.rslt ->+>+<.rslt ->+>+>-.rslt] rslt]
      sys   +.sys
      ==
    ?:  =(->+<.sys ->+>-.udata)                   :: timestamps equal?
      %=  $
      rslt  [~[name.a ->-.sys ->+<.sys ->-.udata ->+<.udata ->+>-.udata] rslt]
      sys   +.sys
      udata  +.udata
      ==
    ?:  (gth ->+<.sys ->+>-.udata)                :: sys ahead of udata?
      %=  $
      rslt  [~[name.a ->-.rslt ->+<.rslt ->-.udata ->+<.udata ->+>-.udata] rslt]
      udata  +.udata
      ==
    ?>  !=(~ rslt)
    %=  $
    rslt  [~[name.a ->-.sys ->+<.sys ->+>-.rslt ->+>+<.rslt ->+>+>-.rslt] rslt]
    sys   +.sys
    ==
  ++  sys-view-tables
    |_  tables=(map [@tas @tas] table)
    ++  foo
      |=  [k=[@tas @tas] =file]
      ^-  (list (list @))
      =/  aa=(list @)
        ~[-.k +.k ship.file agent.file tmsp.file length.file clustered.file]
      =/  tbl  (~(got by tables) [-.k +.k])
      =/  keys
        %^  spin  columns.pri-indx.tbl
            1
            |=([n=ordered-column:ast a=@] [~[a name.n ascending.n] +(a)])
      =/  columns  
        %^  spin  columns.tbl
            1
            |=([n=column:ast a=@] [`(list @)`~[a name.n type.n] +(a)])
      =/  aaa=(list (list @))  (turn p.keys |=(a=(list @) (weld aa a)))
      =/  b=(list (list @))  ~
      |-  ?~  aaa  b
      %=  $
      b  %:  weld 
             (turn p.columns |=(a=(list @) (weld `(list @)`-.aaa `(list @)`a)))
             b
          ==
      aaa  +.aaa
      ==
    --
  ++  sys-view-columns
    |_  tables=(map [@tas @tas] table)
    ++  foo
      |=  [k=[@tas @tas] =file]
      ^-  (list (list @))
      =/  aa=(list @)  ~[-.k +.k]
      =/  tbl  (~(got by tables) [-.k +.k])
      =/  columns  
        %^  spin  columns.tbl
            1
            |=([n=column:ast a=@] [`(list @)`~[a name.n type.n] +(a)])
     (turn p.columns |=(a=(list @) (weld aa a)))
    --
  ++  do-insert
    |=  [dbs=databases =bowl:gall c=insert:ast]
    ^-  [databases (list cmd-result)]          
    =/  dbrow  
        ~|  "database {<database.table.c>} does not exist" 
        (~(got by dbs) database.table.c)
    =/  db-internals=internals  -.sys.dbrow
    =/  =table
        ~|  "table {<namespace.table.c>}.{<name.table.c>} does not exist"
        (~(got by `tables`->+>+.sys.dbrow) [namespace.table.c name.table.c])
    =/  usr-data=data  -.user-data.dbrow
    =/  =file  
          ~|  "table {<namespace.table.c>}.{<name.table.c>} does not exist" 
          (~(got by files.usr-data) [namespace.table.c name.table.c])
    ::
    =/  col-map  (malt (turn columns.table |=(a=column:ast [+<.a a])))  
    =/  cols=(list column:ast)  ?~  columns.c
      ::  use canonical column list
      columns.table
      ::  validate columns.c length matches, no dups
      ?.  .=  ~(wyt by column-lookup.file) 
              ~(wyt in (silt `(list @t)`(need columns.c)))
        ~|("invalid column: {<columns.c>}" !!)
      %:  turn 
          `(list @t)`(need columns.c) 
          |=(a=@t ~|("invalid column: {<a>}" (~(got by col-map) a)))
      ==
    ?.  ?=([%data *] values.c)  ~|("not implemented: {<values.c>}" !!)
    =/  value-table  `(list (list value-or-default:ast))`+.values.c
    =/  i=@ud  0
    |-
    ?~  value-table  
      :-
        (finalize-data dbs dbrow usr-data file bowl table.c)
        ~[[%result-ud 'row count' i] [%result-da 'data time' now.bowl]]
    ~|  "insert {<namespace.table.c>}.{<name.table.c>} row {<+(i)>}"
    =/  row=(list value-or-default:ast)  -.value-table
    =/  key-pick  %:  turn 
                      columns.pri-indx.table 
                      |=(a=ordered-column:ast (make-key-pick name.a cols))
                  ==
    =/  row-key  
        %:  turn
            key-pick 
            |=(a=[p=@tas q=@ud] (key-atom [p.a (snag q.a row) col-map]))
        ==
    =/  map-row=(map @tas @)  (malt (row-cells row cols))
    =/  mycomp  ((on (list [@tas ?]) (map @tas @)) ~(order idx-comp key.file))
    =.  pri-idx.file
      ?:  (has:mycomp pri-idx.file row-key)  
        ~|("cannot add duplicate key: {<row-key>}" !!)
      (put:mycomp pri-idx.file row-key map-row)
    =.  data.file             [map-row data.file]
    =.  length.file           +(length.file)
    $(i +(i), value-table `(list (list value-or-default:ast))`+.value-table)
++  finalize-data
  |=  [dbs=databases =db-row =data =file =bowl:gall table=qualified-object:ast]
   =.  ship.file          src.bowl
   =.  agent.file         %agent
   =.  tmsp.file          now.bowl
   =.  ship.data          src.bowl
   =.  agent.data         %agent
   =.  tmsp.data          now.bowl
   =.  files.data       (~(put by files.data) [namespace.table name.table] file)
   =.  -.user-data.db-row  data
   (~(put by dbs) database.table db-row)
++  key-atom
  |=  a=[p=@tas q=value-or-default:ast r=(map @tas column:ast)]
  ^-  @
  ?:  ?=(dime q.a)  
    ?.  =(%default p.q.a)  q.q.a     
    ?:  =(%da type:(~(got by r.a) p.a))  *@da    :: default to bunt
    0
  ~|("key atom {<q.a>} not supported" !!)
++  row-cells
  |=  a=[p=(list value-or-default:ast) q=(list column:ast)]
  ^-  (list [@tas @])
  =/  cells=(list [@tas @])  ~
  |-
  ?~  p.a  cells
  %=  $
    cells  [(row-cell -.p.a -.q.a) cells]
    p.a  +.p.a
    q.a  +.q.a
  ==
++  row-cell
  |=  a=[p=value-or-default:ast q=column:ast]
  ^-  [@tas @]
  =/  q  
    ?:  ?=(dime p.a)  
      ?:  =(%default p.p.a)
        ?:  =(%da type.q.a)  *@da                :: default to bunt
        0 
      ?:  =(p.p.a type.q.a)  q.p.a
      ~|("type of column {<name.q.a>} does not match input value type" !!)
    ~|("row cell {<p.a>} not suppoerted" !!)
  [name.q.a q]
++  make-key-pick
  |=  b=[key=@tas a=(list column:ast)]
  =/  i  0
  |-
  ?:  =(key.b name:(snag i a.b))  [key.b i]
  $(i +(i))

++  rdc-set-func
  |=  =(tree set-function:ast)
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
  |=  [dbs=databases =bowl:gall =create-namespace:ast]
  ^-  databases
  ?.  =(our.bowl src.bowl)  ~|("namespace must be created by local agent" !!)
  =/  dbrow  ~|  "database {<database-name.create-namespace>} does not exist" 
                 (~(got by dbs) database-name.create-namespace)
  =/  db-internals=internals  -.sys.dbrow
  =/  namespaces  ~|  "namespace {<name.create-namespace>} already exists"
                      %:  map-insert 
                          namespaces.db-internals 
                          name.create-namespace 
                          now.bowl
                      ==
  =.  -.sys.dbrow  %:  internals 
                       %internals 
                       %agent 
                       now.bowl 
                       namespaces 
                       tables.db-internals
                       ==
  (~(put by dbs) database-name.create-namespace dbrow)  :: prefer upd
++  create-tbl
  |=  [dbs=databases =bowl:gall =create-table:ast]
  ^-  databases
  ?.  =(our.bowl src.bowl)  ~|("table must be created by local agent" !!)
  =/  dbrow  ~|  "database {<database.table.create-table>} does not exist"
                 (~(got by dbs) database.table.create-table)
  =/  db-internals=internals  -.sys.dbrow
  =/  usr-data=data           -.user-data.dbrow
  ?.  (~(has by namespaces.db-internals) namespace.table.create-table)
    ~|("namespace {<namespace.table.create-table>} does not exist" !!)
  =/  col-set  (name-set (silt columns.create-table))
  ?.  =((lent columns.create-table) ~(wyt in col-set))
    ~|("dulicate column names {<columns.create-table>}" !!)
  =/  key-col-set  (name-set (silt pri-indx.create-table))
  =/  key-count  ~(wyt in key-col-set)
  ?.  =((lent pri-indx.create-table) key-count)
    ~|("dulicate column names in key {<columns.create-table>}" !!)
  ?.  =(key-count ~(wyt in (~(int in col-set) key-col-set)))
    ~|("key column not in column definitions {<pri-indx.create-table>}" !!)
  ::
  =/  table  %:  table
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
  =/  tables  
    ~|  "{<name.table.create-table>} exists in {<namespace.table.create-table>}"
    %:  map-insert
        tables.db-internals
        [namespace.table.create-table name.table.create-table]
        table
    ==
  ::
  =/  column-look-up  (malt (spun columns.create-table make-col-lu-data))
  ::
  =/  file  %:  file
                %file
                src.bowl
                %agent
                now.bowl
                clustered.create-table
                0
                column-look-up
                (make-index-key column-look-up pri-indx.create-table)
                ~ 
                ~
            ==
  =/  files  
    ~|  "{<name.table.create-table>} exists in {<namespace.table.create-table>}"
    %:  map-insert
        files.usr-data
        [namespace.table.create-table name.table.create-table]
        file
    ==
  ::
  =.  -.sys.dbrow  %:  internals
                       %internals
                       %agent
                       now.bowl
                       namespaces.db-internals
                       tables
                       ==
  =.  -.user-data.dbrow  %:  data
                             %data
                             src.bowl
                             %agent
                             now.bowl
                             files
                             ==
  (~(put by dbs) database.table.create-table dbrow)  :: prefer upd
++  make-col-lu-data
    |=  [=column:ast a=@]
    ^-  [[@tas [@tas @ud]] @ud]
    [[name.column [type.column a]] +(a)]
++  make-index-key
  |=  [column-lookup=(map @tas [@tas @ud]) pri-indx=(list ordered-column:ast)]
  ^-  (list [@tas ?])
  =/  a=(list [@tas ?])  ~
  |-
  ?~  pri-indx  (flop a)
  =/  b=ordered-column:ast  -.pri-indx
  =/  col  (~(got by column-lookup) name.b)
  %=  $
    pri-indx  +.pri-indx
    a  [[-.col ascending.b] a]
  ==
++  drop-tbl
  |=  [dbs=databases =bowl:gall d=drop-table:ast]
  ^-  databases
  ?.  =(our.bowl src.bowl)  ~|("table must be dropd by local agent" !!)
  =/  dbrow  ~|  "database {<database.table.d>} does not exist" 
             (~(got by dbs) database.table.d)
  =/  db-internals=internals  -.sys.dbrow
  =/  usr-data=data           -.user-data.dbrow
  ?.  (~(has by namespaces.db-internals) namespace.table.d)
    ~|("namespace {<namespaces.internals>} does not exist" !!)
  =/  tables  
    ~|  "{<name.table.d>} does not exists in {<namespace.table.d>}"
    %+  map-delete
        tables.db-internals
        [namespace.table.d name.table.d]
  =/  file  ~|  "table {<namespace.table.d>}.{<name.table.d>} does not exist" 
            (~(got by files.usr-data) [namespace.table.d name.table.d])
  ?:  ?&((gth length.file 0) =(force.d %.n))
    ~|("table {<name.table.d>} has data, use FORCE to DROP" !!)
  =/  files  
    %+  map-delete
        files.usr-data
        [namespace.table.d name.table.d]
  =.  -.sys.dbrow  %:  internals
                       %internals
                       %agent
                       now.bowl
                       namespaces.db-internals
                       tables
                       ==
  =.  -.user-data.dbrow  %:  data
                             %data
                             src.bowl
                             %agent
                             now.bowl
                             files
                             ==
  (~(put by dbs) database.table.d dbrow)  :: prefer upd
++  update-state
  |=  [current=databases next=databases]
  ^-  databases
  =/  a=(list [[@tas db-row] [@tas db-row]])  
        (fuse [~(tap by current) ~(tap by next)])
  |-
  ?~  a  current
  =/  cur-db-row=db-row         -<+.a
  =/  next-db-row=db-row        ->+.a
  =/  cur-internals=internals   -.sys.cur-db-row
  =/  next-internals=internals  -.sys.next-db-row
  =/  cur-data=data             -.user-data.cur-db-row
  =/  next-data=data            -.user-data.next-db-row
  ::
  ?:  ?&  =(tmsp.cur-internals tmsp.next-internals) 
          =(tmsp.cur-data tmsp.next-data)
      ==
    $(a +.a)
  =/  dbrow=db-row  (~(got by current) -<-.a)
  =?  sys.dbrow  !=(tmsp.cur-internals tmsp.next-internals)  
                 [next-internals sys.dbrow]
  =?  user-data.dbrow  !=(tmsp.cur-data tmsp.next-data)  
                       [next-data user-data.dbrow]
  $(a +.a, current (~(put by current) -<-.a dbrow))
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
++  idx-comp 
  |_  index=(list [@tas ascending=?])
  ++  order
    |=  [p=(list @) q=(list @)]
    =/  k=(list [@tas ascending=?])  index
    |-  ^-  ?
    ?:  =(-.p -.q)  $(k +.k, p +.p, q +.q)
    ?:  =(-<.k %t)  (aor -.p -.q)
    ?:  ->.k  (lth -.p -.q)
    (gth -.p -.q)
  --
++  order-row
  |_  index=(list [@tas ascending=? offset=@ud])  :: to do: accomadate varying row types
  ++  order
  |=  [p=(list @) q=(list @)]
  =/  k=(list [@tas ascending=? offset=@ud])  index
  |-  ^-  ?
  ?~  k  %.n
  =/  pp=(list @)
    ?:  =(0 ->+.k)  p                      ::offset of current index
    (oust [0 ->+.k] p)
  =/  qq=(list @)
    ?:  =(0 ->+.k)  q                      ::offset of current index
    (oust [0 ->+.k] q)
  ?:  =(-.pp -.qq)  $(k +.k)
  ?:  =(-<.k %t)  (aor -.pp -.qq)
  ?:  ->-.k  (lth -.pp -.qq)
  (gth -.pp -.qq)
  --
--
