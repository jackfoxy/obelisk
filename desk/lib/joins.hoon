/-  ast, *obelisk
/+  *sys-views, *utils
|_  [state=server =bowl:gall]
::
::  +license:  MIT+n license
++  license
  ^-  @  %-  crip
  "Original Copyright 2024 Jack Fox".
  " ".
  "Permission is hereby granted, free of charge, to any person obtaining a ".
  "copy of this software and associated documentation files ".
  "(the \"Software\"), to deal in the Software without restriction, ".
  "including without limitation the rights to use, copy, modify, merge, ".
  "publish, distribute, sublicense, and/or sell copies of the Software, ".
  "and to permit persons to whom the Software is furnished to do so, ".
  "subject to the following conditions: ".
  " ".
  "The above original copyright notice, this permission notice and the words".
  " ".
  "\"I AM - CHRIST LIVES - SATAN BE GONE\"".
  "  ".
  "shall be included in all copies or substantial portions of the Software, ".
  "as well as the story".
  " ".
  "\"Jesus was crucified for exposing the corruption of the ruling class and ".
  "their rulers, the bankers\"".
  ",".
  " all unaltered.".
  " ".
  "THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, ".
  "EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF ".
  "MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. ".
  "IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,".
  " DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR ".
  "OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE ".
  "USE OR OTHER DEALINGS IN THE SOFTWARE."

::
::  +mk-relations:  [relation (list joined-object:ast)] ->  (list relation)
::
::  put all cross joins at the end of the list
++  mk-relations
  |=  [relat=relation joins=(list joined-object:ast)]
  ^-  (list relation)
  =/  relations=(list relation)    ~[relat]
  =/  cross-joins=(list relation)  ~
  |-
  ?~  joins  (flop (weld cross-joins relations))
  ?:  ?=(%cross-join join.i.joins)
    %=  $
      joins  t.joins
      cross-joins  :-  %:  relation  %relation
                                  object.i.joins
                                  as-of.i.joins
                                  `join.i.joins
                                  predicate.i.joins
                                  ==
                       cross-joins
    ==
  %=  $
    joins  t.joins
    relations  :-  %:  relation  %relation
                                 object.i.joins
                                 as-of.i.joins
                                 `join.i.joins
                                 predicate.i.joins
                                 ==
                   relations
  ==
::
::  +join-all  query:ast -> join-return
::
::  when no joins: returns from-obj
::  otherwise:     returns joined
++  join-all
  |=  q=query:ast
  ^-  join-return
  =/  from  (need from.q)
  =/  relations=(list relation)
        %+  mk-relations  (relation %relation object.from as-of.from ~ ~)
                          joins.from
  =/  selected-columns
        %+  skim  columns.selection.q
                  |=(a=selected-column:ast ?=(qualified-column:ast a))
  =/  relat=relation  -.relations
  =.  relations       +.relations
  =/  query-obj=qualified-object:ast
      ?:  ?=(qualified-object:ast object.table-set.relat)
        object.table-set.relat
      ~|("SELECT: not supported on %query-row" !!)   :: %query-row support
                                         :: %selection composition
  =/  sys-time  (set-tmsp as-of.relat now.bowl)
  =/  db=database  ~|  "SELECT: database {<database.query-obj>} does not exist"
                  (~(got by state) database.query-obj)
  =/  =schema  ~|  "SELECT: database {<database.query-obj>} ".
                    "doesn't exist at time {<sys-time>}"
               (get-schema [sys.db sys-time])
  =/  vw  (get-view [namespace.query-obj name.query-obj sys-time] views.schema)
  =/  alias  ?:  ?=(qualified-object:ast object.table-set.relat)
               ?~  alias.object.table-set.relat  ~
               `(crip (cass (trip (need alias.object.table-set.relat))))
             ~|("not supported" !!)
  =/  yy  ?~  vw  %:  from-table  query-obj
                                  alias
                                  db
                                  schema
                                  ~
                                  [~ ~]
                                  sys-time
                                  ~
                                  ~
                                  ==
          %:  from-view  query-obj
                          alias
                          db
                          schema
                          (need vw)
                          relat
                          sys-time
                          ~
                          ~
                          ==
  =/  init-map=(map qualified-object:ast (map @tas @))  ~
  =/  prior-obj=from-obj                                -.yy
  =/  from-objects=(list from-obj)                      (limo ~[prior-obj])
  =/  prior-join   
        %:  joined  %joined
                    ?~  pri-indx.prior-obj  ~
                    key:(need pri-indx.prior-obj)
                    rowcount.prior-obj
                    %+  turn  indexed-rows.prior-obj
              |=(a=indexed-row [-.a (~(put by init-map) object.prior-obj +.a)])
                    ==
  =/  type-lookup=lookup-type                 +<.yy
  =/  qualified-columns=(list qual-col-type)  +>.yy
  ::
  |-
  ?~  relations
        %:  join-return  %join-return
                         state
                         (flop from-objects)
                         prior-join
                         type-lookup
                         qualified-columns
                         ==
  =.  relat      -.relations
  =/  query-obj=qualified-object:ast
        ?:  ?=(qualified-object:ast object.table-set.relat)
          object.table-set.relat
        ~|("query-source {<object.table-set.relat>} not supported" !!)
  =/  sys-time   (set-tmsp as-of.relat now.bowl)
  =/  db=database    ~|  "SELECT: database {<database.query-obj>} ".
                         "does not exist"
                         (~(got by state) database.query-obj)
  =/  schema         ~|  "SELECT: database {<database.query-obj>} ".
                         "doesn't exist at time {<sys-time>}"
                         (get-schema [sys.db sys-time])
  =/  vw  (get-view [namespace.query-obj name.query-obj sys-time] views.schema)
  =.  alias  ?:  ?=(qualified-object:ast object.table-set.relat)
               ?~  alias.object.table-set.relat  ~
               `(crip (cass (trip (need alias.object.table-set.relat))))
             ~|("not supported" !!)
  ::
  =/  xx  ?~  vw
            %:  from-table  query-obj
                            alias
                            db
                            schema
                            join.relat
                            predicate.relat
                            sys-time
                            type-lookup
                            qualified-columns
                            ==
          %:  from-view  query-obj
                          alias
                          db
                          schema
                          (need vw)
                          relat
                          sys-time
                          type-lookup
                          qualified-columns
                          ==
  ::
  %=  $
    relations          +.relations
    from-objects       [-.xx from-objects]
    prior-join         (join-up prior-join -.xx)
    type-lookup        +<.xx
    qualified-columns  +>.xx
  ==
::
++  from-table
  |=  $:  query-obj=qualified-object:ast
          alias=(unit @t)
          db=database
          =schema
          join=(unit join-type:ast)
          predicate=(unit predicate:ast)
          sys-time=@da
          type-lookup=lookup-type
          qualified-columns=(list qual-col-type)
          ==
  ^-  [from-obj lookup-type (list qual-col-type)]
  =/  tbl  ~|  "SELECT: table {<database.query-obj>}.{<namespace.query-obj>}".
               ".{<name.query-obj>} does not exist at schema time ".
               "{<tmsp.schema>}"
           (~(got by tables.schema) [namespace.query-obj name.query-obj])
  =/  file
        (get-content content.db sys-time [namespace.query-obj name.query-obj])
  :+
    %:  from-obj  %from-obj
                  query-obj
                  tmsp.tbl
                  tmsp.file
                  columns.tbl
                  [~ pri-indx.tbl]
                  join
                  predicate
                  rowcount.file
                  pri-idx.file
                  indexed-rows.file
                  ==
    %+  ~(put by type-lookup)  
          query-obj
          column-types.tbl
    (mk-qualified-columns query-obj qualified-columns columns.tbl)
::
++  mk-qualified-columns
  |=  $:  query-obj=qualified-object:ast
          qualified-columns=(list qual-col-type)
          columns=(list column:ast)
          ==
  ?~  qualified-columns
        %+  turn  columns
                |=(a=column:ast (mk-qualified-column query-obj a))
  %+  weld  qualified-columns
                %+  turn  columns
                |=(a=column:ast (mk-qualified-column query-obj a))
::
++  mk-qualified-column
  |=  [query-obj=qualified-object:ast a=column:ast]
  ^-  qual-col-type
  [(qualified-column:ast %qualified-column query-obj name.a ~) type.a]
::
++  from-view
  |=  $:  query-obj=qualified-object:ast
          alias=(unit @t)
          db=database
          =schema
          =view
          relat=relation
          sys-time=@da
          type-lookup=lookup-type
          qualified-columns=(list qual-col-type)
          ==
  ^-  [from-obj lookup-type (list qual-col-type)]
  =/  r=[database cache]  %:  got-view-cache  db
                                              schema
                                              view
                                              :+  namespace.query-obj
                                                  name.query-obj
                                                  sys-time
                                              ==
  =/  view-content  (need content.+.r)
  ::
  ::  database view cache may have been populated
  =.  state  ?.  =(db -.r)
                (~(put by state) database.query-obj -.r)
             state
  :+
    %:  from-obj  %from-obj
                  query-obj
                  tmsp.schema
                  tmsp.+.r
                  columns.view
                  ~
                  join.relat
                  predicate.relat
                  rowcount.view-content
                  ~
                  %+  turn  rows.view-content
                            |=(a=(map @tas @) [~ a])
                  ==
    %+  ~(put by type-lookup)  
          query-obj
          column-types.view
    (mk-qualified-columns query-obj qualified-columns columns.view)
::
::  +got-view-cache:
::    [database schema view data-obj-key (list selected-column:ast)]
::    -> [database cache]
++  got-view-cache
  |=  [db=database =schema vw=view key=data-obj-key]
  ^-  [database cache]
  =/  vw-cache=cache  (get-view-cache key view-cache.db)
  ?.  =(content.vw-cache ~)  [db vw-cache]
  =.  content.vw-cache  ?:  =(ns.key 'sys')
                              :-  ~
                                  %:  populate-system-view  state
                                                            db
                                                            schema
                                                            vw
                                                            obj.key
                                                            tmsp.vw-cache
                                                            ==
                                !!  :: : implement view refresh for non-sys
  [(put-view-cache db vw-cache key) vw-cache]
::
++  join-up
  |=  [prior=joined this=from-obj]
  ^-  joined
  ?-  (need join.this)
    %join
      ?:  =(~ predicate.this)  (join-natural prior this)
      ~|("%join with ON predicate not implemented" !!)
    %left-join
      ~|("%left-join not implemented" !!)
    %right-join
      ~|("right-join not implemented" !!)
    %outer-join
      ~|("%outer-join not implemented" !!)
    %cross-join
      (cross-join prior this)
  ==
::
::  +cross-join:  [joined from-obj] -> joined
++  cross-join
  |=  [prior=joined this=from-obj]
  ^-  joined
  =/  a=(list joined-row)  joined-rows.prior
  =/  out-rows=(list joined-row)  ~
  =/  i  0
  ::
  |-
  ?~  a  (joined %joined ~ i out-rows)
  =/  b  indexed-rows.this
  |-
  ?~  b  ^$(a +.a)
  =/  data-row  -.a
  %=  $ 
    out-rows  :-  :-  ~
                      (~(put by +.data-row) object.this ->.b)
                  out-rows
    b  +.b
    i  +(i)
  ==
::
++  reduce-ord-col
  |=  a=ordered-column:ast
  name.a
::
::  +join-natural:  [joined from-obj] -> joined
++  join-natural
  |=  [prior=joined this=from-obj]
  ^-  joined
  ::join on foreign keys (to do)
  ::
  ::join on primary key
  ?:  &(=(~ key.prior) =(~ pri-indx.this))
    ~|("no natural join, missing index: {<prior>} {<this>}" !!)
  =/  this-key  key:(need pri-indx.this)
  :: perfect natural join
  ?:  =(key.prior this-key)
      %^  joined  %joined
                  this-key
                  %:  join-pri-key  joined-rows.prior
                                    indexed-rows.this
                                    object.this
                                    this-key
                                    ==
  ::  key is same column sequence, but different ordering
  ?:  ?!  .=  (turn key.prior |=(a=key-column [name.a aura.a]))
              (turn this-key |=(a=key-column [name.a aura.a]))
    ~|  "no natural join or foreign key join, columns do not match: ".
        "{<object.this>}"
        !!
  ::  sort the little one
  =/  the-key  ?:  (gth rowcount.this rowcount.prior)
                 this-key
               key.prior
  =/  count-and-rows
        ?:  (gth rowcount.this rowcount.prior)
          %:  join-pri-key  %+  sort  joined-rows.prior
                                      ~(order idx-comp-2 (reduce-key the-key))
                            indexed-rows.this
                            object.this
                            this-key
                            ==
        %:  join-pri-key  joined-rows.prior
                          %+  sort  indexed-rows.this
                                    ~(order idx-comp-2 (reduce-key the-key))
                          object.this
                          key.prior
                          ==
 (joined %joined the-key -.count-and-rows +.count-and-rows)
::
::  +join-pri-key
::
::  joins the data of two tables having the same key
++  join-pri-key
  |=  $:  a=(list joined-row)
          b=(list indexed-row)
          b-qual=qualified-object:ast
          key=(list key-column)
          ==
  ^-  [@ud (list joined-row)]
  =/  c=(list joined-row)  ~
  =/  i  0
  ::
  |-
  ?~  a  [i (flop c)]
  ?~  b  [i (flop c)]
  =/  data-row  -.a
  ?:  =(-<.a -<.b)              :: keys =
    %=  $ 
      c  [[-.data-row (~(put by +.data-row) b-qual ->.b)] c]
      a  +.a
      b  +.b
      i  +(i)
    ==
  ?:  (~(order idx-comp (reduce-key key)) -<.a -<.b)
    $(a +.a)
  $(b +.b)
--