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
++  join-all
  |=  =from:ast
  ^-  [server (list from-obj)]

  ?~  relations.from  ~|("no query objects" !!)

  =/  relat=relation:ast  -.relations.from
  =/  =table-set:ast      table-set.relat
  =/  relations           +.relations.from
  =/  query-obj=qualified-object:ast
      ?:  ?=(qualified-object:ast object.table-set)  object.table-set
      ~|("SELECT: not supported on %query-row" !!)   :: %query-row non-sense to support
                                         :: %selection composition
  =/  sys-time  (set-tmsp as-of.relat now.bowl)
  =/  db=database  ~|  "SELECT: database {<database.query-obj>} does not exist"
                  (~(got by state) database.query-obj)
  =/  =schema  ~|  "SELECT: database {<database.query-obj>} ".
                    "doesn't exist at time {<sys-time>}"
               (get-schema [sys.db sys-time])
  =/  vw  (get-view [namespace.query-obj name.query-obj sys-time] views.schema)
  ::
  =/  from-objects=(list from-obj)
      %-  limo  :~  ?~  vw  %:  from-table  query-obj
                                            db
                                            schema
                                            ~
                                            [~ ~]
                                            sys-time
                                            ~
                                            ~
                                            ==
                        %:  from-view  query-obj
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
  ::
  =/  prior=from-obj  -.from-objects
  =/  joined-obj  ?~  vw  %:  from-table  query-obj
                                              db
                                              schema
                                              join.relat
                                              predicate.relat
                                              sys-time
                                              type-lookup.prior
                                              qualified-columns.prior
                                              ==
                      %:  from-view  query-obj
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
                rows.file
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
          db=database
          =schema
          =view
          relat=relation:ast
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
                rows.view-content
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
  ^-  (list (map qualified-object:ast (map @tas @)))
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
      ~|("%cross-join not implemented" !!)
  ==
++  join-natural
  |=  [prior=from-obj this=from-obj]
  ^-  (list (map qualified-object:ast (map @tas @)))
  ::join on foreign keys (to do)
  ::
  ::join on pri-key
  =/  column-set-1  (silt columns:(need pri-indx.prior))
  =/  column-set-2  (silt columns:(need pri-indx.this))
  =/  join-columns
    ?:  ?&  ?!(?|(=(~ pri-indx.prior) =(~ pri-indx.this)))
            .=  (lent columns:(need pri-indx.this))
                ~(wyt in (~(int in column-set-1) column-set-2))
            ==
      columns:(need pri-indx.this)
    (~(int in (silt columns.prior)) (silt columns.this))  ::join on like columns
  ?~  join-columns  ~|  "no natural or foreign key join ".
                        "{<object.prior>} {<object.this>}"
                        !!
  %:  join-pri-key  (tap:(pri-key key.prior) pri-indexed.prior)
                    (tap:(pri-key key.this) pri-indexed.this)
                    object.prior
                    object.this
                    key.this
                    ==
::
++  join-pri-key
  |=  $:  a=(list [(list @) (map @tas @)])
          b=(list [(list @) (map @tas @)])
          a-qual=qualified-object:ast
          b-qual=qualified-object:ast
          key=(list [@tas ?])
          ==
  ^-  (list (map qualified-object:ast (map @tas @)))
  =/  c=(list (map qualified-object:ast (map @tas @)))  ~
  =/  init-map=(map qualified-object:ast (map @tas @))  ~
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