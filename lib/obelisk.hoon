/-  ast, *obelisk
/+  *sys-views, u=utils  ::to do: recreate 2 faceless bug /+  *sys-views, *utils
::/+  *utils, *sys-views
|%
++  new-database
  |=  [state=databases =bowl:gall c=command:ast]
  ^-  [databases result]
  ?:  =(+<.c %sys)  ~|("database name cannot be 'sys'" !!)
  ?>  ?=(create-database:ast c)
  =/  sys-time  (set-tmsp as-of:`create-database:ast`c now.bowl)
  =/  ns=namespaces  (my ~[[%sys sys-time] [%dbo sys-time]])
  ::
  =/  db-views  :~  :-  [%sys %namespaces sys-time]
                        %-  apply-ordering
                            (sys-namespaces-view +<.c sap.bowl sys-time)
                    :-  [%sys %tables sys-time]
                        %-  apply-ordering
                            (sys-tables-view +<.c sap.bowl sys-time)
                    :-  [%sys %columns sys-time]
                        %-  apply-ordering
                            (sys-columns-view +<.c sap.bowl sys-time)
                    :-  [%sys %sys-log sys-time]
                        %-  apply-ordering
                            (sys-sys-log-view +<.c sap.bowl sys-time)
                    :-  [%sys %data-log sys-time]
                        %-  apply-ordering
                            (sys-data-log-view +<.c sap.bowl sys-time)
                    ==
  =/  vws=views  %+  gas:view-key  *((mop data-obj-key view) ns-obj-comp)
                                   (limo db-views)
  ::
  ::  first time add sys database
  =/  next-state  ?.  (~(has by state) %sys)
                    (sys-database state bowl sys-time)
                  state
  ::
  :-  %:  map-insert:u  next-state  
                        +<.c  
                        %:  database  %database 
                                      +<.c 
                                      sap.bowl
                                      sys-time
                                      :+  :-  sys-time
                                              %:  schema  %schema
                                                          sap.bowl
                                                          sys-time
                                                          ns
                                                          ~
                                                          vws
                                                          ~
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
      [%result-da 'system time' sys-time]
++  sys-database
  |=  [state=databases =bowl:gall sys-time=@da]
  ^-  databases
  =/  ns=namespaces  (my ~[[%sys sys-time]])
  =/  db-views  :~  :-  [%sys %databases sys-time]
                        (apply-ordering (sys-sys-dbs-view sap.bowl sys-time))
                    ==
  =/  vws=views  %+  gas:view-key  *((mop data-obj-key view) ns-obj-comp)
                                   (limo db-views)
  %:  map-insert:u  state  
                  %sys  
                  %:  database  %database 
                                %sys 
                                sap.bowl
                                sys-time
                                :+  :-  sys-time
                                        %:  schema  %schema
                                                    sap.bowl
                                                    sys-time
                                                    ns
                                                    ~
                                                    vws
                                                    ~
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
++  process-cmds
  |=  [state=databases =bowl:gall cmds=(list command:ast)]
  ^-  [(list cmd-result) databases]
  =/  next-schemas=(map @tas [(unit schema) (unit data)])  ~
  =/  next-data=(map @tas [(unit schema) (unit data)])  ~
  =/  results=(list cmd-result)  ~
  =/  query-has-run=?  %.n
  |-  
  ?~  cmds  :-  (flop results)
                (update-state state next-schemas next-data)
  ?-  -<.cmds
    %alter-index
      ?:  query-has-run  ~|("alter index state change after query in script" !!)
      !!
    %alter-namespace
      ?:  query-has-run  
        ~|("alter namespace state change after query in script" !!)
      !!
    %alter-table
      ?:  query-has-run  ~|("alter table state change after query in script" !!)
      !!
    %create-database  ~|("create database must be only command in script" !!)
    %create-index
      ?:  query-has-run
        ~|("create-index state change after query in script" !!)
      !!
    %create-namespace
      ?:  query-has-run
        ~|("create namespace state change after query in script" !!)
      =/  r=[@da (map @tas [(unit schema) (unit data)])]
            (create-ns state bowl -.cmds next-schemas next-data)
      %=  $
        next-schemas  +.r
        cmds          +.cmds
        results       :- 
                          :-  %results
                            (limo ~[[%result-da 'system time' -.r]])
                          results
      ==
    %create-table
      ?:  query-has-run
        ~|("create table state change after query in script" !!)
      =/  r=table-return
            (create-tbl state bowl -.cmds next-schemas next-data)
      %=  $
        next-schemas  +<.r
        next-data     +>.r
        cmds          +.cmds
        results     :-
                      :-  %results
                          (limo ~[[%result-da 'system time' -<.r]])
                        results
      ==
    %create-view
      ?:  query-has-run  ~|("create view state change after query in script" !!)
      !!
    %drop-database
      !!
    %drop-index
      ?:  query-has-run  ~|("drop index state change after query in script" !!)
      !!
    %drop-namespace
      ?:  query-has-run
        ~|("drop namespace state change after query in script" !!)
      !!
    %drop-table
      ?:  query-has-run  ~|("drop table state change after query in script" !!)
      =/  r=table-return  
            (drop-tbl state bowl -.cmds next-schemas next-data)
      %=  $
        next-schemas  +<.r
        next-data     +>.r
        cmds          +.cmds
        results
          ?:  ->-.r
            :-  :-  %results
                    %-  limo  :~  [%result-da 'system time' -<.r]
                                  [%result-da 'data time' -<.r]
                                  [%result-ud 'row count' ->+.r]
                                  ==
                results
          :-
            :-  %results
                (limo ~[[%result-da 'system time' -<.r]])
            results
      ==
    %drop-view
      ?:  query-has-run  ~|("drop view state change after query in script" !!)
      !!
    %grant
      !!
    %revoke
      !!
    %transform
      =/  r=[? [(map @tas [(unit schema) (unit data)]) (list result)]]
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
        results         [[%results +>.r] results]
      ==
    %truncate-table
      ?:  query-has-run
        ~|("truncate table state change after query in script" !!)
      =/  r=table-return  
            (truncate-tbl state bowl -.cmds next-schemas next-data)
      %=  $
        next-schemas  +<.r
        next-data     +>.r
        cmds          +.cmds
        results
          ?.  ->-.r
            :-  [%results (limo ~[[%message 'no data in table to truncate']])]
                results
          :-  :-  %results 
                  %-  limo  :~  [%result-da 'data time' -<.r]
                                [%result-ud 'row count' ->+.r]
                                ==
              results
          
      ==
  ==
++  do-transform
  |=  $:  query-has-run=?
          state=databases
          =bowl:gall
          =transform:ast
          next-data=(map @tas [(unit schema) (unit data)])
          next-schemas=(map @tas [(unit schema) (unit data)])
      ==
  ^-  [? [(map @tas [(unit schema) (unit data)]) (list result)]]

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
  
  ^-  [? [(map @tas [(unit schema) (unit data)]) (list result)]]
  =/  rtree  (~(rdc of tree) rdc-set-func)
  ?-  -<.rtree
    %delete
      ?:  query-has-run  ~|("delete state change after query in script" !!)
      !!
    %insert
      ?:  query-has-run  ~|("insert state change after query in script" !!)
      [%.n (do-insert state bowl -.rtree next-data next-schemas)]
    %update
      ?:  query-has-run  ~|("update state change after query in script" !!)
      !!
    %query
      [%.y [next-data (do-query state bowl -.rtree next-data next-schemas)]]
  ::    ~&  >  "-.rtree: {<-.rtree>}"
  ::    ~&  >  "+.rtree: {<+.rtree>}"
  ::    ?>  ?=(query:ast -.rtree)
  ::    `query:ast`-.rtree
  ::    -.rtree

  ::    !!
    %merge
      ?:  query-has-run  ~|("merge state change after query in script" !!)
      !!
    == 
++  do-query
  |=  $:  state=databases
          =bowl:gall
          q=query:ast
          next-data=(map @tas [(unit schema) (unit data)])
          next-schemas=(map @tas [(unit schema) (unit data)])
          ==
  ^-  (list result)
  ?~  from.q  ~[(select-literals columns.selection.q)]
  =/  =from:ast  (need from.q)
  =/  =table-set:ast  object.from
  =/  query-obj=qualified-object:ast
        ?:  ?=(qualified-object:ast object.table-set)
          `qualified-object:ast`object.table-set
        ~|("not supported" !!)
  :: to do: restore after backing out %query-row
  =/  data=(list row)  ?:   =(namespace.query-obj 'sys')
                              (view-data state now.bowl query-obj)
                            `(list row)`~
  ~[[%result-set data]]
++  select-literals
  |=  columns=(list selected-column:ast)
  ^-  result
  =/  i  0             ::to do: return row count
  =/  vals=(list cell)  ~
  |-
  ?~  columns  [%result-set (limo ~[(row %row (flop vals))])]
  ?.  ?=(selected-value:ast -.columns)
    ~|("selected value {<-.columns>} not a literal" !!)
  =/  column=selected-value:ast  -.columns
  =/  heading=@tas  ?~  alias.column  (crip "literal-{<i>}")
                    (need alias.column)
  %=  $
    i        +(i)
    columns  +.columns
    vals     [(cell heading value.column) vals]
  ==
::
++  view-data
  |=  [state=databases sys-time=@da q=qualified-object:ast]
  ^-  (list row)
  =/  db=database  ~|  "database {<database.q>} does not exist"
                  (~(got by state) database.q)
  =/  =schema
        ~|  "database {<database.q>} does not exist at time {<sys-time>}"
        (get-schema:u [sys.db sys-time])
  =/  vw  (get-view:u [namespace.q name.q sys-time] views.schema)
  ::=/  clean-vw  ?:  =(is-dirty.vw %.y)
                  ?:  =(namespace.q 'sys')  
                    %:  populate-system-view  state
                                              db 
                                              schema 
                                              vw
                                              name.q
                                              ==
                  !!  :: to do:  implement view refresh for non-sys
  ::              vw
  ::content.clean-vw
::
++  do-insert
  |=  $:  state=databases
          =bowl:gall
          c=insert:ast
          next-data=(map @tas [(unit schema) (unit data)])
          next-schemas=(map @tas [(unit schema) (unit data)])
      ==
    :: to do: aura validation?

  ^-  [(map @tas [(unit schema) (unit data)]) (list result)]
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
    ?.  =(~(wyt by column-lookup.file) (lent (need columns.c)))
      ~|("insert invalid column: {<columns.c>}" !!)
    %+  turn 
        `(list @t)`(need columns.c) 
        |=(a=@t ~|("insert invalid column: {<a>}" (~(got by col-map) a)))
  ::
  ?.  ?=([%data *] values.c)  ~|("not implemented: {<values.c>}" !!)
  =/  value-table  `(list (list value-or-default:ast))`+.values.c
  =/  i=@ud  0
  =/  key-pick  %+  turn 
                    columns.pri-indx.table 
                    |=(a=ordered-column:ast (make-key-pick name.a cols))
  |-
  ?~  value-table  
    :-  (finalize-data nxt-data file bowl sys-time table.c next-data)
        ~[[%result-ud 'row count' i] [%result-da 'data time' sys-time]]
  ~|  "insert {<namespace.table.c>}.{<name.table.c>} row {<+(i)>}"
  =/  row=(list value-or-default:ast)  -.value-table
  =/  row-key  
      %+  turn
          key-pick 
          |=(a=[p=@tas q=@ud] (key-atom:u [p.a (snag q.a row) col-map]))
  =/  map-row=(map @tas @)  (malt (row-cells row cols))
  =.  pri-idx.file
    ?:  (has:(pri-key:u key.file) pri-idx.file row-key)  
      ~|("cannot add duplicate key: {<row-key>}" !!)
    (put:(pri-key:u key.file) pri-idx.file row-key map-row)
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
       ~|  "namespace {<name.create-namespace>} as-of content time out of order"
          %:  get-next-data  content.db  :: for date checking purposes
                              next-data
                              sys-time
                              database-name.create-namespace
                              ==
  =.  namespaces.nxt-schema
        ~|  "namespace {<name.create-namespace>} already exists"
        %:  map-insert:u 
            namespaces.nxt-schema 
            name.create-namespace 
            sys-time
        ==
  =.  tmsp.nxt-schema        sys-time
  =.  provenance.nxt-schema  sap.bowl
  =.  views.nxt-schema  
      (next-views views.nxt-schema database-name.create-namespace bowl sys-time)
  ::
  :-  sys-time
      (~(put by next-schemas) database-name.create-namespace [`nxt-schema ~])
++  filter  skim
++  next-views
    |=  [=views db=@tas =bowl:gall sys-time=@da]
    ^+  views 
    ::  To Do: remove all except most most recent of non-sys views
    =/  a  |=([=data-obj-key =view] !=(%sys ns.data-obj-key))
    =/  next-db-views=(list [=data-obj-key =view])
          %-  limo  :~  :-  [%sys %namespaces sys-time]
                             %-  apply-ordering
                                 (sys-namespaces-view db sap.bowl sys-time)
                         :-  [%sys %tables sys-time]
                             %-  apply-ordering
                                 (sys-tables-view db sap.bowl sys-time)
                         :-  [%sys %columns sys-time]
                             %-  apply-ordering
                                 (sys-columns-view db sap.bowl sys-time)
                         :-  [%sys %sys-log sys-time]
                             %-  apply-ordering
                                 (sys-sys-log-view db sap.bowl sys-time)
                         :-  [%sys %data-log sys-time]
                             %-  apply-ordering
                                 (sys-data-log-view db sap.bowl sys-time)
                         ==
    %:  gas:view-key  *((mop data-obj-key view) ns-obj-comp) 
                      %:  weld  (filter (tap:view-key views) a) 
                                `(list [=data-obj-key =view])`next-db-views
                                ==
                      ==
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
    %:  map-insert:u
        tables.nxt-schema
        [namespace.table.create-table name.table.create-table]
        table
    ==
  =.  tables.nxt-schema      tables
  =.  tmsp.nxt-schema        sys-time
  =.  provenance.nxt-schema  sap.bowl
  =.  views.nxt-schema  
        (next-views views.nxt-schema database.table.create-table bowl sys-time)
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
    %:  map-insert:u
        files.nxt-data
        [namespace.table.create-table name.table.create-table]
        file
    ==
  =.  files.nxt-data       files
  =.  tmsp.nxt-data        sys-time
  =.  provenance.nxt-data  sap.bowl
  ::
  :+  [sys-time %.n 0]
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
    %+  map-delete:u
        tables.nxt-schema
        [namespace.table.d name.table.d]
  =.  tables.nxt-schema      tables
  =.  tmsp.nxt-schema        sys-time
  =.  provenance.nxt-schema  sap.bowl
  ::
  =/  file
        ~|  "drop table {<namespace.table.d>}.{<name.table.d>} does not exist" 
            (~(got by files.nxt-data) [namespace.table.d name.table.d])
  ?:  ?&((gth length.file 0) =(force.d %.n))
    ~|("drop table {<name.table.d>} has data, use FORCE to DROP" !!)
  =/  dropped-data=?  (gth length.file 0)
  =/  files  
    %+  map-delete:u
        files.nxt-data
        [namespace.table.d name.table.d]
  =.  files.nxt-data       files
  =.  tmsp.nxt-data        sys-time
  =.  provenance.nxt-data  sap.bowl
  =.  views.nxt-schema  
        (next-views views.nxt-schema database.table.d bowl sys-time)
  ::
  :+  [sys-time dropped-data length.file]
      (~(put by next-schemas) database.table.d [`nxt-schema ~])
      (~(put by next-data) database.table.d [~ `nxt-data])
++  truncate-tbl
  |=  $:  state=databases
          =bowl:gall
          d=truncate-table:ast
          next-schemas=(map @tas [(unit schema) (unit data)])
          next-data=(map @tas [(unit schema) (unit data)])
          ==
  ^-  table-return
  =/  db  ~|  "database {<database.table.d>} does not exist" 
             (~(got by state) database.table.d)
  =/  sys-time  (set-tmsp as-of.d now.bowl)
  =/  nxt-schema=schema
        ~|  "truncate table {<name.table.d>} as-of schema time out of order"
          %:  get-next-schema  sys.db
                              next-schemas
                              sys-time
                              database.table.d
                              ==
  =/  nxt-data=data
        ~|  "truncate table {<name.table.d>} as-of data time out of order"
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
    %-  ~(got by tables:nxt-schema)
        [namespace.table.d name.table.d]
  ::
  =/  file
    ~|  "truncate table {<namespace.table.d>}.{<name.table.d>} does not exist" 
        (~(got by files.nxt-data) [namespace.table.d name.table.d])
  =/  dropped-data=?  (gth length.file 0)
  ?.  dropped-data
    :+  [sys-time dropped-data 0]
      (~(put by next-schemas) database.table.d [`nxt-schema ~])
      (~(put by next-data) database.table.d [~ `nxt-data])
  ::
  =/  dropped-rows  length.file
  =.  data.file     ~
  =.  length.file   0
  =.  tmsp.file     sys-time
  =/  files  (~(put by files.nxt-data) [namespace.table.d name.table.d] file)
  =.  files.nxt-data       files
  =.  tmsp.nxt-data        sys-time
  =.  provenance.nxt-data  sap.bowl
  ::
  :+  [sys-time dropped-data dropped-rows]
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
                          (put:schema-key:u sys.db ->->+>-.a (need ->-.a))
                        ?~  ->+.a  content.db
                          (put:data-key:u content.db ->+>+>+<.a (need ->+.a))
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
::
::  gets the schema with the highest timestamp for mutation
++  get-next-schema
  |=  $:  sys=((mop @da schema) gth)
          next-schemas=(map @tas [(unit schema) (unit data)])
          sys-time=@da
          db-name=@tas
      ==
  ^-  schema
  =/  db-schema  +:(need (pry:schema-key:u sys))    :: latest schema
  =/  nxt-schema=schema  ?:  (~(has by next-schemas) db-name)
                            (need -:(~(got by next-schemas) db-name))
                          db-schema
  ?:  (lth sys-time tmsp.nxt-schema)  !!
  ?:  ?&(=(db-schema nxt-schema) =(tmsp.nxt-schema sys-time))  !!
  nxt-schema
::
::  gets the data with the highest timestamp for mutation
++  get-next-data
  |=  $:  content=(tree [@da data])
          next-data=(map @tas [(unit schema) (unit data)])
          sys-time=@da
          db-name=@tas
      ==
  ^-  data
  =/  db-data  +:(need (pry:data-key:u content))  :: latest data
  =/  nxt-data=data  ?:  (~(has by next-data) db-name)
                        (need +:(~(got by next-data) db-name))
                      db-data
  ?:  (lth sys-time tmsp.nxt-data)  !!
  ?:  ?&(=(db-data nxt-data) =(tmsp.nxt-data sys-time))  !!
  nxt-data
::
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
::
::  helper types
::
+$  table-return
  $:  [@da ? @ud]
      (map @tas [(unit schema) (unit data)])
      (map @tas [(unit schema) (unit data)])
  ==
--
