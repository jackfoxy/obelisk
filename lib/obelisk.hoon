/-  ast, *obelisk
|%
++  new-database
  |=  [state=databases =bowl:gall c=command:ast]
  ^-  [databases cmd-result]
  ?:  =(+<.c %sys)  ~|("database name cannot be 'sys'" !!)
  ?>  ?=(create-database:ast c)
  =/  sys-time  (set-tmsp as-of:`create-database:ast`c now.bowl)
  =/  ns=namespaces  (my ~[[%sys sys-time] [%dbo sys-time]])
  =/  tbs=tables  ~
  :-  %:  map-insert  state  +<.c  %:  database 
                                        %database 
                                        +<.c 
                                        sap.bowl
                                        sys-time
                                        :+  :-  sys-time
                                                %:  schema  %schema
                                                            sap.bowl
                                                            sys-time
                                                            ns
                                                            tbs
                                                ==
                                            ~
                                            ~
                                        :+  :-  sys-time
                                                %:  data  %data
                                                          src.bowl
                                                          sap.bowl
                                                          sys-time
                                                          ~
                                                ==
                                            ~
                                            ~
                                      ==
          ==
      `cmd-result`[%result-da 'system time' sys-time]
++  process-cmds
  |=  [state=databases =bowl:gall cmds=(list command:ast)]
  ^-  [(list cmd-result) databases]
  =/  next-schemas=(map @tas [(unit schema) (unit data)])  ~
  =/  next-data=(map @tas [(unit schema) (unit data)])  ~
  =/  results=(list cmd-result)  ~
  =/  query-has-run=?  %.n
  |-  
  ?~  cmds  :-  [%results (flop results)]
                (update-state state next-schemas next-data)
  ?-  -<.cmds
    %alter-index
      ?:  query-has-run  ~|("state change after query in script" !!)
      !!
    %alter-namespace
      ?:  query-has-run  ~|("state change after query in script" !!)
      !!
    %alter-table
      ?:  query-has-run  ~|("state change after query in script" !!)
      !!
    %create-database  ~|("create database must be only command in script" !!)
    %create-index
      ?:  query-has-run  ~|("state change after query in script" !!)
      !!
    %create-namespace
      ?:  query-has-run  ~|("state change after query in script" !!)
      =/  r=[@da (map @tas [(unit schema) (unit data)])]
            (create-ns state bowl -.cmds next-schemas next-data)
      %=  $
        next-schemas  +.r
        cmds          +.cmds
        results       [`cmd-result`[%result-da 'system time' -.r] results]
      ==
    %create-table
      ?:  query-has-run  ~|("state change after query in script" !!)
      =/  r=table-return
            (create-tbl state bowl -.cmds next-schemas next-data)
      %=  $
        next-schemas  +<.r
        next-data     +>.r
        cmds     +.cmds
        results  [`cmd-result`[%result-da 'system time' -.r] results]
      ==
    %create-view
      ?:  query-has-run  ~|("state change after query in script" !!)
      !!
    %drop-database
      !!
    %drop-index
      ?:  query-has-run  ~|("state change after query in script" !!)
      !!
    %drop-namespace
      ?:  query-has-run  ~|("state change after query in script" !!)
      !!
    %drop-table
      ?:  query-has-run  ~|("state change after query in script" !!)
      =/  r=table-return  
            (drop-tbl state bowl -.cmds next-schemas next-data)
      %=  $
        next-schemas  +<.r
        next-data     +>.r
        cmds          +.cmds
        results       [`cmd-result`[%result-da 'system time' -.r] results]
      ==
    %drop-view
      ?:  query-has-run  ~|("state change after query in script" !!)
      !!
    %grant
      !!
    %revoke
      !!
    %transform
      =/  r=[? [(map @tas [(unit schema) (unit data)]) (list cmd-result)]]
            %:  do-transform  query-has-run
                              state
                              bowl
                              -.cmds
                              next-data
                              next-schemas
                              ==
      %=  $
        query-has-run   -.r
        next-data       +<.r
        cmds            +.cmds
        results         +>.r
      ==
    %truncate-table
      ?:  query-has-run  ~|("state change after query in script" !!)
      !!
  ==
++  do-transform
  |=  $:  query-has-run=?
          state=databases
          =bowl:gall
          =transform:ast
          next-data=(map @tas [(unit schema) (unit data)])
          next-schemas=(map @tas [(unit schema) (unit data)])
      ==
  ^-  [? [(map @tas [(unit schema) (unit data)]) (list cmd-result)]]

  =/  ctes=(list cte:ast)  ctes.transform  :: To Do - map CTEs
  %:  do-set-functions  query-has-run
                        state 
                        bowl
                        set-functions.transform
                        next-data
                        next-schemas
                        ==
++  do-set-functions
  |=  $:  query-has-run=?
          state=databases
          =bowl:gall
          =(tree set-function:ast)
          next-data=(map @tas [(unit schema) (unit data)])
          next-schemas=(map @tas [(unit schema) (unit data)])
      ==
  ::  =/  rtree  ^+((~(rdc of tree) foo) tree)
  ::  =/  rtree  `(tree set-function:ast)`(~(rdc of tree) foo)
  ::  =/  rtree=(tree set-function:ast)  (~(rdc of tree) foo)
  ::  ?~  rtree  !!  :: fuse loop
  
  ^-  [? [(map @tas [(unit schema) (unit data)]) (list cmd-result)]]
  =/  rtree  (~(rdc of tree) rdc-set-func)
  ?-  -<.rtree
    %delete
      ?:  query-has-run  ~|("state change after query in script" !!)
      !!
    %insert
      ?:  query-has-run  ~|("state change after query in script" !!)
      [%.n (do-insert state bowl -.rtree next-data next-schemas)]
    %update
      ?:  query-has-run  ~|("state change after query in script" !!)
      !!
    %query
      [%.y [next-data (do-query state bowl -.rtree)]]
  ::    ~&  >  "-.rtree: {<-.rtree>}"
  ::    ~&  >  "+.rtree: {<+.rtree>}"
  ::    ?>  ?=(query:ast -.rtree)
  ::    `query:ast`-.rtree
  ::    -.rtree

  ::    !!
    %merge
      ?:  query-has-run  ~|("state change after query in script" !!)
      !!
    == 
  ++  do-query
    |=  [state=databases =bowl:gall q=query:ast]
    ^-  (list cmd-result)
    ?~  from.q  ~[(select-literals columns.selection.q)]
    =/  =from:ast  (need from.q)
    =/  =table-set:ast  object.from
    ?:  ?&  ?=(qualified-object:ast object.table-set)
            =(namespace.object.table-set 'sys')
        ==
      ~[(sys-views state bowl object.table-set)]
    !!
  ++  select-literals
    |=  columns=(list selected-column:ast)
    ^-  cmd-result
    =/  i  0
    =/  cols=(list [@tas @tas])  ~
    =/  vals=(list @)  ~
    |-
    ?~  columns  :^(%result-set ~.literals (flop cols) ~[(flop vals)])
    ?.  ?=(selected-value:ast -.columns)
      ~|("selected value {<-.columns>} not a literal" !!)
    =/  column=selected-value:ast  -.columns
    =/  heading=[@tas @tas]  
      ?~  alias.column  [(crip "literal-{<i>}") p.value.column]
      [(need alias.column) p.value.column]
    %=  $
      i        +(i)
      columns  +.columns
      cols     [heading cols]
      vals     [q.value.column vals]
    ==
  ++  sys-views
    |=  [state=databases =bowl:gall q=qualified-object:ast]
    ^-  cmd-result
    ?:  =(%databases name.q)
      ?.  ?&(=(%sys database.q) =(%sys namespace.q))
        ~|("databases view only in database namespace 'sys.sys'" !!)
      =/  databases-order  ~[[%t %.y 0] [%da %.y 2] [%da %.y 5]]
      =/  dbes             (turn ~(val by state) sys-view-databases)
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
    =/  db  
      ~|  "database {<database.q>} does not exist" 
      (~(got by state) database.q)
    =/  sys=schema  (get-schema now.bowl sys.db)
    =/  =tables     tables.sys
    =/  udata=data  (get-data now.bowl content.db)
    ?+  name.q  !!
    %columns
      =/  columns-order  ~[[%t %.y 0] [%t %.y 1] [%ud %.y 2]]
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
    %sys-log
      :: to do: rewrite as jagged when architecture available
      =/  sys-order   ~[[%da %.n 0] [%t %.y 2] [%t %.y 3]]
      =/  sys=(list schema)
            (turn (tap:schema-key sys.db) |=(b=[@da schema] +.b))
      =/  namespaces  (zing (turn sys sys-view-sys-log-ns))
      =/  tbls        (zing (turn sys sys-view-sys-log-tbl))
      =/  log         (weld `(list (list @))`namespaces `(list (list @))`tbls)
      :^
      %result-set
      `@ta`(crip (weld (trip database.q) ".sys.sys-log"))
      ~[[%tmsp %da] [%agent %tas] [%component %tas] [%name %tas]]
      (sort `(list (list @))`log ~(order order-row sys-order))
    ::
    %data-log
      =/  data-order   ~[[%da %.n 0] [%t %.y 3] [%t %.y 4]]
      =/  tbls  
            %-  zing  
                %+  turn  (turn (tap:data-key content.db) |=(b=[@da data] +.b)) 
                          sys-view-data-log
      :^
      %result-set
      `@ta`(crip (weld (trip database.q) ".sys.data-log"))
      ~[[%tmsp %da] [%ship %p] [%agent %tas] [%namespace %tas] [%table %tas]]
      (sort `(list (list @))`tbls ~(order order-row data-order))
    ==
  ++  sys-view-data-log
    |=  a=data
    ^-  (list (list @))
    =/  tbls  %+  skim
                  %~  val  by
                      (~(urn by files.a) |=([k=[@tas @tas] =file] [k file]))
                  |=(b=[k=[@tas @tas] =file] =(tmsp.a tmsp.file.b))
    %+  turn
          tbls
   |=([k=[@tas @tas] =file] ~[tmsp.a ship.a (crip (spud provenance.a)) -.k +.k])
  ++  sys-view-sys-log-tbl
    |=  a=schema
    ^-  (list (list @))
    =/  tbls  %+  skim
                  %~  val  by
                      (~(urn by tables.a) |=([k=[@tas @tas] =table] [k table]))
                  |=(b=[k=[@tas @tas] =table] =(tmsp.a tmsp.table.b))
    %+  turn  tbls
      |=([k=[@tas @tas] =table] ~[tmsp.a (crip (spud provenance.a)) -.k +.k])
  ++  sys-view-sys-log-ns
    |=  a=schema
    ^-  (list (list @))
    =/  namespaces  %+  skim  
                    ~(val by (~(urn by namespaces.a) |=([k=@tas v=@da] [k v])))
                    |=(b=[ns=@tas tmsp=@da] =(tmsp.a tmsp.b))
    %+  turn  namespaces
      |=([ns=@tas tmsp=@da] ~[tmsp.a (crip (spud provenance.a)) %namespace ns])
  ++  sys-view-databases
    |=  a=database
    ^-  (list (list @))
    =/  sys=(list schema)
          (flop (turn (tap:schema-key sys.a) |=(b=[@da schema] +.b)))
    =/  udata=(list data)
          (flop (turn (tap:data-key content.a) |=(b=[@da data] +.b)))
    =/  rslt=(list (list @))  ~
        |-
        ?:  ?&(=(~ sys) =(~ udata))  (flop rslt)
        ?~  sys
          %=  $
            rslt  :-  :~  name.a
                          ->-.rslt
                          ->+<.rslt
                          ->-.udata
                          (crip (spud ->+<.udata))
                          ->+>-.udata
                      ==
                      rslt
            udata  +.udata
          ==
    ::to do: test cases for sys ahead and behind of udata
        ?~  udata
          ?>  !=(~ rslt)
          %=  $
            rslt  :-  :~  name.a
                          (crip (spud ->-.sys))
                          ->+<:sys
                          ->+>-.rslt
                          ->+>+<.rslt
                          ->+>+>-.rslt
                      ==
                      rslt
            sys   +.sys
          ==
        ?:  =(->+<.sys ->+>-.udata)                   :: timestamps equal?
          %=  $
            rslt  :-  :~  name.a
                          (crip (spud ->-.sys))
                          ->+<.sys
                          ->-.udata
                          (crip (spud ->+<.udata))
                          ->+>-.udata
                      ==
                      rslt
            sys   +.sys
            udata  +.udata
          ==
        ?:  (gth ->+<.sys ->+>-.udata)                :: sys ahead of udata?
          %=  $
            rslt  :-  :~  name.a
                          ->-.rslt
                          ->+<.rslt
                          ->-.udata
                          (crip (spud ->+<.udata))
                          ->+>-.udata
                      ==
                      rslt
            udata  +.udata
          ==
        ?>  !=(~ rslt)
        %=  $
          rslt  :-  :~  name.a
                        (crip (spud ->-.sys))
                        ->+<.sys
                        ->+>-.rslt
                        ->+>+<.rslt
                        ->+>+>-.rslt
                    ==
                    rslt
          sys   +.sys
        ==
  ++  sys-view-tables
    |_  tables=(map [@tas @tas] table)
    ++  foo
      |=  [k=[@tas @tas] =file]
      ^-  (list (list @))
      =/  aa=(list @)  :~  -.k
                          +.k
                          ship.file
                          (crip (spud provenance.file))
                          tmsp.file
                          length.file
                          clustered.file
                        ==
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
      b  %+  weld 
             (turn p.columns |=(a=(list @) (weld `(list @)`-.aaa `(list @)`a)))
             b
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
    |=  $:  state=databases
            =bowl:gall
            c=insert:ast
            next-data=(map @tas [(unit schema) (unit data)])
            next-schemas=(map @tas [(unit schema) (unit data)])
        ==
    ^-  [(map @tas [(unit schema) (unit data)]) (list cmd-result)]
    =/  db  
        ~|  "database {<database.table.c>} does not exist" 
        (~(got by state) database.table.c)
    =/  sys-time  (set-tmsp as-of.c now.bowl)
    =/  nxt-data=data
        ~|  "insert into table {<name.table.c>} as-of data time out of order"
          %:  get-next-data  content.db
                              next-data
                              sys-time
                              database.table.c
                              ==
    =/  nxt-schema=schema
          ~|  "insert into table {<name.table.c>} ".
              "as-of schema time out of order"
          %:  get-next-schema  sys.db
                            next-schemas
                            sys-time
                            database.table.c
                            ==
    =/  =table
        ~|  "table {<namespace.table.c>}.{<name.table.c>} does not exist"
        %-  ~(got by tables:nxt-schema)
            [namespace.table.c name.table.c]
    =/  =file  
          ~|  "table {<namespace.table.c>}.{<name.table.c>} does not exist" 
          (~(got by files.nxt-data) [namespace.table.c name.table.c])
    ::
    =/  col-map  (malt (turn columns.table |=(a=column:ast [+<.a a])))  
    =/  cols=(list column:ast)  ?~  columns.c
      ::  use canonical column list
      columns.table
      ::  validate columns.c length matches, no dups
      ?.  .=  ~(wyt by column-lookup.file) 
              ~(wyt in (silt `(list @t)`(need columns.c)))
        ~|("invalid column: {<columns.c>}" !!)
      %+  turn 
          `(list @t)`(need columns.c) 
          |=(a=@t ~|("invalid column: {<a>}" (~(got by col-map) a)))
    ?.  ?=([%data *] values.c)  ~|("not implemented: {<values.c>}" !!)
    =/  value-table  `(list (list value-or-default:ast))`+.values.c
    =/  i=@ud  0
    |-
    ?~  value-table  
      :-  (finalize-data nxt-data file bowl sys-time table.c next-data)
          ~[[%result-ud 'row count' i] [%result-da 'data time' sys-time]]
    ~|  "insert {<namespace.table.c>}.{<name.table.c>} row {<+(i)>}"
    =/  row=(list value-or-default:ast)  -.value-table
    =/  key-pick  %+  turn 
                      columns.pri-indx.table 
                      |=(a=ordered-column:ast (make-key-pick name.a cols))
    =/  row-key  
        %+  turn
            key-pick 
            |=(a=[p=@tas q=@ud] (key-atom [p.a (snag q.a row) col-map]))
    =/  map-row=(map @tas @)  (malt (row-cells row cols))
    =.  pri-idx.file
      ?:  (has:(pri-key key.file) pri-idx.file row-key)  
        ~|("cannot add duplicate key: {<row-key>}" !!)
      (put:(pri-key key.file) pri-idx.file row-key map-row)
    =.  data.file             [map-row data.file]
    =.  length.file           +(length.file)
    $(i +(i), value-table `(list (list value-or-default:ast))`+.value-table)
++  finalize-data
  |=  $:  nxt-data=data
          =file
          =bowl:gall
          sys-time=@da
          table=qualified-object:ast
          next-data=(map @tas [(unit schema) (unit data)])
      ==
  ^-  (map @tas [(unit schema) (unit data)])
  =.  ship.file          src.bowl
  =.  provenance.file    sap.bowl
  =.  tmsp.file          sys-time
  ::
  =.  ship.nxt-data        src.bowl
  =.  provenance.nxt-data  sap.bowl
  =.  files.nxt-data
        (~(put by files.nxt-data) [namespace.table name.table] file)
  =.  tmsp.nxt-data        sys-time
  (~(put by next-data) database.table [~ `nxt-data])
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
  |=  $:  state=databases
          =bowl:gall
          =create-namespace:ast
          next-schemas=(map @tas [(unit schema) (unit data)])
          next-data=(map @tas [(unit schema) (unit data)])
      ==
  ^-  [@da (map @tas [(unit schema) (unit data)])]
  ?.  =(our.bowl src.bowl)  ~|("schema changes must be by local agent" !!)
  =/  db  ~|  "database {<database-name.create-namespace>} does not exist" 
                 (~(got by state) database-name.create-namespace)
  =/  sys-time  (set-tmsp as-of.create-namespace now.bowl)
  =/  nxt-schema=schema  
        ~|  "namespace {<name.create-namespace>} as-of schema time out of order"
          %:  get-next-schema  sys.db
                            next-schemas
                            sys-time
                            database-name.create-namespace
                            ==
  =/  dummy  
        ~|  "drop table {<name.create-namespace>} as-of data time out of order"
          %:  get-next-data  content.db  :: for date checking purposes
                              next-data
                              sys-time
                              database-name.create-namespace
                              ==
  =/  namespaces  ~|  "namespace {<name.create-namespace>} already exists"
                      %:  map-insert 
                          namespaces.nxt-schema 
                          name.create-namespace 
                          sys-time
                      ==
  =.  namespaces.nxt-schema  namespaces
  =.  tmsp.nxt-schema        sys-time
  =.  provenance.nxt-schema  sap.bowl
  :-  sys-time
      (~(put by next-schemas) database-name.create-namespace [`nxt-schema ~])
++  create-tbl
  |=  $:  state=databases
          =bowl:gall
          =create-table:ast
          next-schemas=(map @tas [(unit schema) (unit data)])
          next-data=(map @tas [(unit schema) (unit data)])
          ==
  ^-  table-return
  ?.  =(our.bowl src.bowl)  ~|("table must be created by local agent" !!)
  =/  db  ~|  "database {<database.table.create-table>} does not exist"
                 (~(got by state) database.table.create-table)
  =/  sys-time  (set-tmsp as-of.create-table now.bowl)
  =/  nxt-schema=schema
        ~|  "table {<name.table.create-table>} as-of schema time out of order"
          %:  get-next-schema  sys.db
                              next-schemas
                              sys-time
                              database.table.create-table
                              ==
  =/  nxt-data=data
        ~|  "table {<name.table.create-table>} as-of data time out of order"
          %:  get-next-data  content.db
                              next-data
                              sys-time
                              database.table.create-table
                              ==
  ::
  ?.  (~(has by namespaces.nxt-schema) namespace.table.create-table)
    ~|("namespace {<namespace.table.create-table>} does not exist" !!)
  =/  col-set  (name-set (silt columns.create-table))
  ?.  =((lent columns.create-table) ~(wyt in col-set))
    ~|("duplicate column names {<columns.create-table>}" !!)
  =/  key-col-set  (name-set (silt pri-indx.create-table))
  =/  key-count  ~(wyt in key-col-set)
  ?.  =((lent pri-indx.create-table) key-count)
    ~|("duplicate column names in key {<columns.create-table>}" !!)
  ?.  =(key-count ~(wyt in (~(int in col-set) key-col-set)))
    ~|("key column not in column definitions {<pri-indx.create-table>}" !!)
  ::
  =/  table  %:  table
                 %table
                 sap.bowl
                 sys-time
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
        tables.nxt-schema
        [namespace.table.create-table name.table.create-table]
        table
    ==
  =.  tables.nxt-schema      tables
  =.  tmsp.nxt-schema        sys-time
  =.  provenance.nxt-schema  sap.bowl
  ::
  =/  column-look-up  (malt (spun columns.create-table make-col-lu-data))
  ::
  =/  file  %:  file
                %file
                src.bowl
                sap.bowl
                sys-time
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
        files.nxt-data
        [namespace.table.create-table name.table.create-table]
        file
    ==
  =.  files.nxt-data       files
  =.  tmsp.nxt-data        sys-time
  =.  provenance.nxt-data  sap.bowl
  ::
  :+  sys-time
      (~(put by next-schemas) database.table.create-table [`nxt-schema ~])
      (~(put by next-data) database.table.create-table [~ `nxt-data])
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
  |=  $:  state=databases
          =bowl:gall
          d=drop-table:ast
          next-schemas=(map @tas [(unit schema) (unit data)])
          next-data=(map @tas [(unit schema) (unit data)])
          ==
  ^-  table-return
  ?.  =(our.bowl src.bowl)  ~|("table must be dropped by local agent" !!)
  =/  db  ~|  "database {<database.table.d>} does not exist" 
             (~(got by state) database.table.d)
  =/  sys-time  (set-tmsp as-of.d now.bowl)
  =/  nxt-schema=schema
        ~|  "drop table {<name.table.d>} as-of schema time out of order"
          %:  get-next-schema  sys.db
                              next-schemas
                              sys-time
                              database.table.d
                              ==
  =/  nxt-data=data
        ~|  "drop table {<name.table.d>} as-of data time out of order"
          %:  get-next-data  content.db
                              next-data
                              sys-time
                              database.table.d
                              ==
  ::
  ?.  (~(has by namespaces.nxt-schema) namespace.table.d)
    ~|("namespace {<namespaces.nxt-schema>} does not exist" !!)
  ::
  =/  tables  
    ~|  "{<name.table.d>} does not exists in {<namespace.table.d>}"
    %+  map-delete
        tables.nxt-schema
        [namespace.table.d name.table.d]
  =.  tables.nxt-schema      tables
  =.  tmsp.nxt-schema        sys-time
  =.  provenance.nxt-schema  sap.bowl
  ::
  =/  file  ~|  "table {<namespace.table.d>}.{<name.table.d>} does not exist" 
            (~(got by files.nxt-data) [namespace.table.d name.table.d])
  ?:  ?&((gth length.file 0) =(force.d %.n))
    ~|("table {<name.table.d>} has data, use FORCE to DROP" !!)
  =/  files  
    %+  map-delete
        files.nxt-data
        [namespace.table.d name.table.d]
  =.  files.nxt-data       files
  =.  tmsp.nxt-data        sys-time
  =.  provenance.nxt-data  sap.bowl
  ::
  :+  sys-time
      (~(put by next-schemas) database.table.d [`nxt-schema ~])
      (~(put by next-data) database.table.d [~ `nxt-data])
++  update-state
  |=  $:  state=databases
          next-schemas=(map @tas [(unit schema) (unit data)])
          next-data=(map @tas [(unit schema) (unit data)])
      ==
  ^-  databases
  =/  a=(list [[@tas [(unit schema) (unit data)]]])
        ~(tap by (~(uni2 by2 next-schemas) next-data))
  |-
  ?~  a  state
  =/  db=database  (~(got by state) -<.a)
  =/  next-db-state  %:  database  %database 
                        name.db 
                        created-provenance.db
                        created-tmsp.db
                        ?~  ->-.a  sys.db
                          (put:schema-key sys.db ->->+>-.a (need ->-.a))
                        ?~  ->+.a  content.db
                          (put:data-key content.db ->+>+>+<.a (need ->+.a))
                        ==
  $(a +.a, state (~(put by state) -<.a next-db-state))
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
  ?:  (~(has by m) key)  ~|("duplicate key: {<key>}" !!)
  (~(put by m) key value)
++  map-delete
  |*  [m=(map) key=*]
  ^+  m
  ?:  (~(has by m) key)  (~(del by m) key)
  ~|("deletion key does not exist: {<key>}" !!)
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
++  pri-key
  |=  key=(list [@tas ?])
  ((on (list [@tas ?]) (map @tas @)) ~(order idx-comp key))
++  schema-key  ((on @da schema) gth)
++  data-key  ((on @da data) gth)
::
::  gets the schema with matching or highest timestamp prior to
++  get-schema
  |=  [time=@da sys=(tree [@da schema])]
  ^-  schema
  =/  exact  (get:schema-key sys time)
  ?^  exact  (need exact)
  =/  prior  (pry:schema-key (lot:schema-key sys `time ~))
  ?~  prior  ~|("schema not available for {<time>}" !!)
  +:(need prior)
::
::  gets the schema with the highest timestamp for mutation
++  get-next-schema
  |=  $:  sys=(tree [@da schema])
          next-schemas=(map @tas [(unit schema) (unit data)])
          sys-time=@da
          db-name=@tas
      ==
  ^-  schema
  =/  db-schema  +:(need (pry:schema-key sys))  :: latest schema
  =/  nxt-schema=schema  ?:  (~(has by next-schemas) db-name)
                            (need -:(~(got by next-schemas) db-name))
                          db-schema
  ?:  (lth sys-time tmsp.nxt-schema)  !!
  ?:  ?&(=(db-schema nxt-schema) =(tmsp.nxt-schema sys-time))  !!
  nxt-schema
::
::  gets the data with matching or highest timestamp prior to
++  get-data
  |=  [time=@da sys=(tree [@da data])]
  ^-  data
  =/  exact  (get:data-key sys time)
  ?^  exact  (need exact)
  =/  prior  (pry:data-key (lot:data-key sys `time ~))
  ?~  prior  ~|("data not available for {<time>}" !!)
  +:(need prior)
::
::  gets the data with the highest timestamp for mutation
++  get-next-data
  |=  $:  content=(tree [@da data])
          next-data=(map @tas [(unit schema) (unit data)])
          sys-time=@da
          db-name=@tas
      ==
  ^-  data
  =/  db-data  +:(need (pry:data-key content))  :: latest data
  =/  nxt-data=data  ?:  (~(has by next-data) db-name)
                        (need +:(~(got by next-data) db-name))
                      db-data
  ?:  (lth sys-time tmsp.nxt-data)  !!
  ?:  ?&(=(db-data nxt-data) =(tmsp.nxt-data sys-time))  !!
  nxt-data
::
++  order-row
  |_  index=(list [@tas ascending=? offset=@ud])  
  :: to do: accomadate varying row types
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
++  set-tmsp
  |=  [p=(unit as-of:ast) q=@da]
  ^-  @da
  ?~  p  q
  =/  as-of=as-of:ast  (need p)
  ?:  ?=([%da @] as-of)  +.as-of
  ?:  ?=([%dr @] as-of)  (sub q +.as-of)
  ?-  units.as-of
    %seconds
      (sub q `@dr`(yule `tarp`[0 0 0 offset:as-of ~]))
    %minutes
      (sub q `@dr`(yule `tarp`[0 0 offset:as-of 0 ~]))
    %hours
      (sub q `@dr`(yule `tarp`[0 offset:as-of 0 0 ~]))
    %days
      (sub q `@dr`(yule `tarp`[offset:as-of 0 0 0 ~]))
    %weeks
      (sub q `@dr`(yule `tarp`[(mul offset:as-of 7) 0 0 0 ~]))
    %months
      =/  foo    (yore q)
      =/  years  (div offset:as-of 12)
      =/  months  (sub offset:as-of (mul years 12))
      ?:  =(m.foo months)
        %-  year  :+  [a=%.y y=(sub y.foo (add years 1))]
                      m=12
                      t=[d=d.t.foo h=h.t.foo m=m.t.foo s=s.t.foo f=f.t.foo]
      ?:  (gth m.foo months)
        %-  year  :+  [a=%.y y=(sub y.foo years)]
                      m=(sub m.foo months)
                      t=[d=d.t.foo h=h.t.foo m=m.t.foo s=s.t.foo f=f.t.foo]
      %-  year  :+  [a=%.y y=(sub y.foo (add years 1))]
                    m=(sub (add m.foo 12) months)
                    t=[d=d.t.foo h=h.t.foo m=m.t.foo s=s.t.foo f=f.t.foo]
    %years
      =/  foo  (yore q)
      %-  year  :+  [a=%.y y=(sub y.foo offset:as-of)]
                    m=m.foo
                    t=[d=d.t.foo h=h.t.foo m=m.t.foo s=s.t.foo f=f.t.foo]
  ==
++  by2
  =|  a=(tree (pair * [* *]))  ::  (map)
  |@
  ++  uni2
    |*  b=_a
    |-  ^+  a
    ?~  b  a
    ?~  a  b
    ?:  =(p.n.b p.n.a)
        b(n [p.n.b [-.q.n.a +.q.n.b]], l $(a l.a, b l.b), r $(a r.a, b r.b))
    ?:  (mor p.n.a p.n.b)
      ?:  (gor p.n.b p.n.a)
        $(l.a $(a l.a, r.b ~), b r.b)
      $(r.a $(a r.a, l.b ~), b l.b)
    ?:  (gor p.n.a p.n.b)
      $(l.b $(b l.b, r.a ~), a r.a)
    $(r.b $(b r.b, l.a ~), a l.a)
  ++  int2                                               ::  intersection
    |*  b=_a
    |-  ^+  a
    ?~  b  ~
    ?~  a  ~
    ?:  (mor p.n.a p.n.b)
      ?:  =(p.n.b p.n.a)
        b(n [p.n.b [-.q.n.a +.q.n.b]], l $(a l.a, b l.b), r $(a r.a, b r.b))
      ?:  (gor p.n.b p.n.a)
        %-  uni2(a $(a l.a, r.b ~))  $(b r.b)
      %-  uni2(a $(a r.a, l.b ~))  $(b l.b)
    ?:  =(p.n.a p.n.b)
      b(l $(b l.b, a l.a), r $(b r.b, a r.a))
    ?:  (gor p.n.a p.n.b)
      %-  uni2(a $(b l.b, r.a ~))  $(a r.a)
    %-  uni2(a $(b r.b, l.a ~))  $(a l.a)
    --
--
