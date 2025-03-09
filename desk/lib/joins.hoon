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
++  join-all
  |=  q=query:ast
  ^-  [server (list from-obj)]
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
  ::
  =/  from-objects=(list from-obj)
      %-  limo  :~  ?~  vw  %:  from-table  query-obj
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
                    ==
  ::
  |-
  ?~  relations  [state (flop from-objects)]
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
  =/  prior=from-obj  -.from-objects
  =/  joined-obj  ?~  vw  %:  from-table  query-obj
                                          alias
                                          db
                                          schema
                                          join.relat
                                          predicate.relat
                                          sys-time
                                          type-lookup.prior
                                          qualified-columns.prior
                                          ==
                      %:  from-view  query-obj
                                     alias
                                     db
                                     schema
                                     (need vw)
                                     relat
                                     sys-time
                                     type-lookup.prior
                                     qualified-columns.prior
                                     ==
  ::
  =.  joined-rows.joined-obj  (join-up prior joined-obj)
  ::
  %=  $
    relations     +.relations
    from-objects  [joined-obj from-objects]
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
          type-lookup=(map qualified-object:ast (map @tas @ta))
          qualified-columns=(list [qualified-column:ast @ta])
          ==
  ^-  from-obj
  =/  tbl  ~|  "SELECT: table {<database.query-obj>}.{<namespace.query-obj>}".
               ".{<name.query-obj>} does not exist at schema time ".
               "{<tmsp.schema>}"
           (~(got by tables.schema) [namespace.query-obj name.query-obj])
  =/  file
        (get-content content.db sys-time [namespace.query-obj name.query-obj])
  %:  from-obj  %from-obj
                query-obj
                 ?~  alias
                    ~
                `(crip (cass (trip (need alias))))
                tmsp.tbl
                tmsp.file
                columns.tbl
                (mk-qualified-columns query-obj qualified-columns columns.tbl)
                key.tbl
                [~ pri-indx.tbl]
                join
                predicate
                %+  ~(put by type-lookup)  
                    query-obj
                    (malt (turn columns.tbl |=(a=column:ast [name.a type.a])))
                rowcount.file
                pri-idx.file
                indexed-rows.file
                ~
                ==
::
++  mk-qualified-columns
  |=  $:  query-obj=qualified-object:ast
          qualified-columns=(list [qualified-column:ast @ta])
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
  ^-  [qualified-column:ast @ta]
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
          type-lookup=(map qualified-object:ast (map @tas @ta))
          qualified-columns=(list [qualified-column:ast @ta])
          ==
  ^-  from-obj
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
  %:  from-obj  %from-obj
                query-obj
                ?~  alias
                    ~
                `(crip (cass (trip (need alias))))
                tmsp.schema
                tmsp.+.r
                columns.view
                (mk-qualified-columns query-obj qualified-columns columns.view)
                ~
                ~
                join.relat
                predicate.relat
                %+  ~(put by type-lookup)  
                    query-obj
                    (malt (turn columns.view |=(a=column:ast [name.a type.a])))
                rowcount.view-content
                ~
                %+  turn  rows.view-content
                          |=(a=(map @tas @) [~ a])
                ~
                ==
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
  |=  [prior=from-obj this=from-obj]
  ^-  (list joined-row)
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
::  +cross-join:  [from-obj from-obj] -> (list joined-row)
++  cross-join
  |=  [prior=from-obj this=from-obj]
  ^-  (list joined-row)
  =/  a  indexed-rows.prior
  =/  out-rows=(list joined-row)  ~
  =/  init-map=joined-row  ~
  ::
  |-
  ?~  a  out-rows
  =/  b  indexed-rows.this 
  |-
  ?~  b  ^$(a +.a)
  %=  $ 
                              :: produce joined vectors
    out-rows  :-  %+  ~(put by (~(put by init-map) object.prior ->.a)) 
                      object.this
                      ->.b
                  out-rows
    b  +.b
  ==
::
++  reduce-ord-col
  |=  a=ordered-column:ast
  name.a
::
::  +join-natural:  [from-obj from-obj] -> (list joined-row)
++  join-natural
  |=  [prior=from-obj this=from-obj]
  ^-  (list joined-row)
  ::join on foreign keys (to do)
  ::
  ::join on primary key
  ?:  ?|(=(~ pri-indx.prior) =(~ pri-indx.this))  ::view may not have index
    ~|("no natural join, missing index: {<object.prior>} {<object.this>}" !!)
  ?:  ?&  =(key.prior key.this)  :: perfect natural join
          =(columns:(need pri-indx.prior) columns:(need pri-indx.this))
          ==
    %:  join-pri-key  indexed-rows.prior
                      indexed-rows.this
                      object.prior
                      object.this
                      key.this
                      ==
  ::  key is same column sequence, but different ordering
  ?:  ?!  ?&  .=  (turn key.prior |=(a=[@ta ?] -.a))
                  (turn key.this |=(a=[@ta ?] -.a))
              .=  (turn columns:(need pri-indx.prior) reduce-ord-col)
                  (turn columns:(need pri-indx.this) reduce-ord-col)
              ==
    ~|  "no natural join or foreign key join , columns do not match: ".
        "{<object.prior>} {<object.this>}"
        !!
  ::  sort the little one
  ?:  (gth rowcount.this rowcount.prior)
    %:  join-pri-key  (sort indexed-rows.prior ~(order idx-comp-2 key.this))
                      indexed-rows.this
                      object.prior
                      object.this
                      key.this
                      ==
  %:  join-pri-key  indexed-rows.prior
                    (sort indexed-rows.this ~(order idx-comp-2 key.prior))
                    object.prior
                    object.this
                    key.prior
                    ==
::
::  +join-pri-key
::
::  joins the data of two tables having the same key
++  join-pri-key
  |=  $:  a=(list [(list @) (map @tas @)])
          b=(list [(list @) (map @tas @)])
          a-qual=qualified-object:ast
          b-qual=qualified-object:ast
          key=(list [@tas ?])
          ==
  ^-  (list joined-row)
  =/  c=(list joined-row)  ~
  =/  init-map=joined-row  ~
  ::
  |-
  ?~  a  c
  ?~  b  c
  ?:  =(-<.a -<.b)              :: keys =
    %=  $ 
                                :: produce joined vectors
      c  :-  %+  ~(put by (~(put by init-map) a-qual ->.a)) 
                 b-qual
                 ->.b
             c

      a  +.a
      b  +.b
    ==
  ?:  (~(order idx-comp key) -<.a -<.b)
    $(a +.a)
  $(b +.b)
--