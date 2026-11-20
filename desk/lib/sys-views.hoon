/-  ast=obelisk-ast, *obelisk, *server-state-2
/+  *utils
|%
::
++  sys-sys-dbs-view
  ::  view name: sys-databases
  ::
  ::  Base data comes from the server map in server-state-2.  For each
  ::  +database, +sys-view-databases merges the +database.sys schema history
  ::  and +database.content data history, carrying the previous side forward
  ::  when only one history changes at a timestamp.
  ::
  ::  The view body is a %crud-txn query over sys.sys.databases.  It exposes
  ::  columns: database, sys-agent, sys-tmsp, data-ship, data-agent,
  ::  data-tmsp.
  ::
  ::  Orders by database, sys-tmsp, then data-tmsp ascending.
  |=  [provenance=path tmsp=@da]
  ^-  view
  =/  columns=(list column:ast)
        %-  addr-columns  :~  [%column %database ~.tas 0]
                              [%column %sys-agent ~.ta 0]
                              [%column %sys-tmsp ~.da 0]
                              [%column %data-ship ~.p 0]
                              [%column %data-agent ~.ta 0]
                              [%column %data-tmsp ~.da 0]
                              ==
  :*  %view
      provenance                                            ::provenance=path
      tmsp                                                  ::tmsp=@da
      :+  %crud-txn                                        ::crud-txn
          ~                                                   ::ctes=(list cte)
          [%query sys-sys-dbs-query]                          ::query
      (malt (spun columns mk-col-lu-data))                  ::column-lookup
      %-  malt
        %+  turn  columns
                  |=(a=column:ast [name.a [type.a addr.a]]) ::typ-addr-lookup
      columns                                           ::columns=(list column)
      ~                                           ::ordering=(list column-order)
      ~                                                     ::indices
      ~                                     ::references
      %.y                                   ::cacheable
      ''                                    ::text
      ==
++  sys-sys-dbs-query
  ^-  query:ast
  :*  %query
          :-  ~           ::from=(unit from)
              :^  %from
                  :*  %qualified-table  ::relation
                      ~
                      %sys
                      %sys
                      %databases
                      ~
                      ==
                  ~  ::(unit as-of)
                  ~  ::joins=(list joined-relatation)
          ~  ::scalars=(list scalar-function)
          ~  ::=predicate
          ~  ::group-by=(list grouping-column)
          ~  ::having=predicate
          :+  %select  ::=select
              ~               ::top=(unit @ud)
              :~  :^  %qualified-column    ::qualified-column
                      :*  %qualified-table  ::qualifier
                          ~                    ::ship=(unit @p)
                          %sys                 ::database=@tas
                          %sys                 ::namespace=@tas
                          %databases           ::name=@tas
                          ~
                          ==
                      %database              ::column=@tas
                      `%database             ::alias=(unit @t)
                  :^  %qualified-column    ::qualified-column
                      :*  %qualified-table  ::qualifier
                          ~                    ::ship=(unit @p)
                          %sys                 ::database=@tas
                          %sys                 ::namespace=@tas
                          %databases           ::name=@tas
                          ~
                          ==
                      %sys-agent             ::column=@tas
                      `%sys-agent            ::alias=(unit @t)
                  :^  %qualified-column    ::qualified-column
                      :*  %qualified-table  ::qualifier
                          ~                  ::ship=(unit @p)
                          %sys               ::database=@tas
                          %sys               ::namespace=@tas
                          %databases         ::name=@tas
                          ~
                          ==
                      %sys-tmsp            ::column=@tas
                      `%sys-tmsp           ::alias=(unit @t)
                  :^  %qualified-column    ::qualified-column
                      :*  %qualified-table  ::qualifier
                          ~                  ::ship=(unit @p)
                          %sys               ::database=@tas
                          %sys               ::namespace=@tas
                          %databases         ::name=@tas
                          ~
                          ==
                      %data-ship           ::column=@tas
                      `%data-ship          ::alias=(unit @t)
                  :^  %qualified-column    ::qualified-column
                      :*  %qualified-table  ::qualifier
                          ~                  ::ship=(unit @p)
                          %sys               ::database=@tas
                          %sys               ::namespace=@tas
                          %databases         ::name=@tas
                          ~
                          ==
                      %data-agent          ::column=@tas
                      `%data-agent         ::alias=(unit @t)
                  :^  %qualified-column    ::qualified-column
                      :*  %qualified-table  ::qualifier
                          ~                  ::ship=(unit @p)
                          %sys               ::database=@tas
                          %sys               ::namespace=@tas
                          %databases         ::name=@tas
                          ~
                          ==
                      %data-tmsp          ::column=@tas
                      `%data-tmsp         ::alias=(unit @t)
                  ==
          :~      ::order-by=(list ordering-column)
              :+  %ordering-column
                  :^  %qualified-column    ::qualified-column
                  :*  %qualified-table  ::qualifier
                      ~           ::ship=(unit @p)
                      %sys        ::database=@tas
                      %sys        ::namespace=@tas
                      %databases  ::name=@tas
                      ~
                      ==
                  %database  ::column=@tas
                  ~  ::alias=(unit @t)
                  %.y  ::ascending=?
              :+  %ordering-column
                  :^  %qualified-column    ::qualified-column
                  :*  %qualified-table  ::qualifier
                      ~           ::ship=(unit @p)
                      %sys        ::database=@tas
                      %sys        ::namespace=@tas
                      %databases  ::name=@tas
                      ~
                      ==
                  %sys-tmsp  ::column=@tas
                  ~  ::alias=(unit @t)
                  %.y  ::ascending=?
              :+  %ordering-column
                  :^  %qualified-column    ::qualified-column
                  :*  %qualified-table  ::qualifier
                      ~           ::ship=(unit @p)
                      %sys        ::database=@tas
                      %sys        ::namespace=@tas
                      %databases  ::name=@tas
                      ~
                      ==
                  %data-tmsp  ::column=@tas
                  ~  ::alias=(unit @t)
                  %.y  ::ascending=?
              ==
          ==
::
++  sys-namespaces-view
  ::  view name: sys-namespaces
  ::
  ::  Base data comes from +schema.namespaces in server-state-2, a map from
  ::  namespace name to the timestamp when that namespace entered the schema.
  ::  +populate-system-view materializes one row per namespace at cache time.
  ::
  ::  The view body is a %crud-txn query over db.sys.namespaces.  It exposes
  ::  columns: namespace, tmsp.
  ::
  ::  Orders by tmsp, then namespace ascending.
  |=  [db=@tas provenance=path tmsp=@da]
  ^-  view
  =/  columns=(list column:ast)
        %-  addr-columns  :~  [%column %namespace ~.tas 0]
                              [%column %tmsp ~.da 0]
                              ==
  :*  %view
      provenance                            ::provenance=path
      tmsp                                  ::tmsp=@da
      :+  %crud-txn                        ::crud-txn
          ~                                   ::ctes=(list cte)
          [%query (sys-namespaces-query db)]  ::query
      (malt (spun columns mk-col-lu-data))  ::column-lookup
      %-  malt
        %+  turn  columns
                  |=(a=column:ast [name.a [type.a addr.a]])  ::typ-addr-lookup
      columns                               ::columns=(list column)
      ~                                     ::ordering=(list column-order)
      ~                                     ::indices
      ~                                     ::references
      %.y                                   ::cacheable
      ''                                    ::text
      ==
++  sys-namespaces-query
  |=  database=@tas
  ^-  query:ast
  :*  %query
          :-  ~           ::from=(unit from)
              :^  %from
                  :*  %qualified-table  ::relation
                      ~
                      database
                      %sys
                      %namespaces
                      ~
                      ==
                  ~  ::(unit as-of)
                  ~               ::joins=(list joined-relatation)
          ~  ::scalars=(list scalar-function)
          ~  ::=predicate
          ~  ::group-by=(list grouping-column)
          ~  ::having=predicate
          :+  %select  ::=select
              ~               ::top=(unit @ud)
              :~  :^  %qualified-column    ::qualified-column
                      :*  %qualified-table  ::qualifier
                          ~                    ::ship=(unit @p)
                          database             ::database=@tas
                          %sys                 ::namespace=@tas
                          %namespaces          ::name=@tas
                          ~
                          ==
                      %namespace             ::column=@tas
                      `%namespace            ::alias=(unit @t)
                  :^  %qualified-column    ::qualified-column
                      :*  %qualified-table  ::qualifier
                          ~                    ::ship=(unit @p)
                          database             ::database=@tas
                          %sys                 ::namespace=@tas
                          %namespaces          ::name=@tas
                          ~
                          ==
                      %tmsp                  ::column=@tas
                      `%tmsp                 ::alias=(unit @t)
                  ==
          :~      ::order-by=(list ordering-column)
              :+  %ordering-column
                  :^  %qualified-column    ::qualified-column
                  :*  %qualified-table  ::qualifier
                      ~            ::ship=(unit @p)
                      database     ::database=@tas
                      %sys         ::namespace=@tas
                      %namespaces  ::name=@tas
                      ~
                      ==
                  %namespace  ::column=@tas
                  ~    ::alias=(unit @t)
                  %.y  ::ascending=?
              ==
          ==
::
++  sys-tables-view
  ::  view name: sys-tables
  ::
  ::  Base data comes from +schema.tables and the cache-time +data.files in
  ::  server-state-2.  +populate-system-view selects the current +data with
  ::  +get-data, walks its file keys, then +sys-view-tables looks up each
  ::  matching +table for provenance and schema timestamp.
  ::
  ::  The view body is a %crud-txn query over db.sys.tables.  It exposes
  ::  columns: namespace, name, agent, tmsp, row-count.  agent is the table
  ::  provenance path rendered as text; row-count comes from the matching
  ::  +file.
  ::
  ::  Orders by namespace, then name ascending.
  |=  [db=@tas provenance=path tmsp=@da]
  ^-  view
  =/  columns=(list column:ast)
        %-  addr-columns  :~  [%column %namespace ~.tas 0]
                              [%column %name ~.tas 0]
                              [%column %agent ~.ta 0]
                              [%column %tmsp ~.da 0]
                              [%column %row-count ~.ud 0]
                              ==
  :*  %view
      provenance                            ::provenance=path
      tmsp                                  ::tmsp=@da
      :+  %crud-txn                        ::crud-txn
          ~                                   ::ctes=(list cte)
          [%query (sys-tables-query db)]      ::query
      (malt (spun columns mk-col-lu-data))  ::column-lookup
      %-  malt
        %+  turn  columns
                  |=(a=column:ast [name.a [type.a addr.a]])  ::typ-addr-lookup
      columns                               ::columns=(list column)
      ~                                     ::ordering=(list column-order)
      ~                                     ::indices
      ~                                     ::references
      %.y                                   ::cacheable
      ''                                    ::text
      ==
++  sys-tables-query
  |=  database=@tas
  ^-  query:ast
  :*  %query
          :-  ~            ::from=(unit from)
              :^  %from
                  :*  %qualified-table  ::relation
                      ~
                      database
                      %sys
                      %tables
                      ~
                      ==
                  ~  ::(unit as-of)
                  ~  ::joins=(list joined-relatation)
          ~  ::scalars=(list scalar-function)
          ~  ::=predicate
          ~  ::group-by=(list grouping-column)
          ~  ::having=predicate
          :+  %select  ::=select
              ~               ::top=(unit @ud)
              :~  :^  %qualified-column    ::qualified-column
                      :*  %qualified-table  ::qualifier
                          ~                    ::ship=(unit @p)
                          database             ::database=@tas
                          %sys                 ::namespace=@tas
                          %tables              ::name=@tas
                          ~                    ::alias=(unit @t)
                          ==
                      %namespace             ::column=@tas
                      `%namespace            ::alias=(unit @t)
                  :^  %qualified-column    ::qualified-column
                      :*  %qualified-table  ::qualifier
                          ~                    ::ship=(unit @p)
                          database             ::database=@tas
                          %sys                 ::namespace=@tas
                          %tables              ::name=@tas
                          ~                    ::alias=(unit @t)
                          ==
                      %name                  ::column=@tas
                      `%name                 ::alias=(unit @t)
                  :^  %qualified-column    ::qualified-column
                      :*  %qualified-table  ::qualifier
                          ~                    ::ship=(unit @p)
                          database             ::database=@tas
                          %sys                 ::namespace=@tas
                          %tables              ::name=@tas
                          ~                    ::alias=(unit @t)
                          ==
                      %agent                 ::column=@tas
                      `%agent                ::alias=(unit @t)
                  :^  %qualified-column    ::qualified-column
                      :*  %qualified-table  ::qualifier
                          ~                    ::ship=(unit @p)
                          database             ::database=@tas
                          %sys                 ::namespace=@tas
                          %tables              ::name=@tas
                          ~                    ::alias=(unit @t)
                          ==
                      %tmsp                  ::column=@tas
                      `%tmsp                 ::alias=(unit @t)
                  :^  %qualified-column    ::qualified-column
                      :*  %qualified-table  ::qualifier
                          ~                  ::ship=(unit @p)
                          database           ::database=@tas
                          %sys               ::namespace=@tas
                          %tables            ::name=@tas
                          ~                    ::alias=(unit @t)
                          ==
                      %row-count           ::column=@tas
                      ~                    ::alias=(unit @t)
                  ==
          :~      ::order-by=(list ordering-column)
              :+  %ordering-column
                  :^  %qualified-column    ::qualified-column
                  :*  %qualified-table  ::qualifier
                      ~           ::ship=(unit @p)
                      database    ::database=@tas
                      %sys        ::namespace=@tas
                      %tables  ::name=@tas
                      ~                    ::alias=(unit @t)
                      ==
                  %namespace  ::column=@tas
                  ~  ::alias=(unit @t)
                  %.y  ::ascending=?
              :+  %ordering-column
                  :^  %qualified-column    ::qualified-column
                  :*  %qualified-table  ::qualifier
                      ~           ::ship=(unit @p)
                      database    ::database=@tas
                      %sys        ::namespace=@tas
                      %tables  ::name=@tas
                      ~                    ::alias=(unit @t)
                      ==
                  %name      ::column=@tas
                  ~  ::alias=(unit @t)
                  %.y  ::ascending=?
              ==
          ==
::
++  sys-table-keys-view
  ::  view name: sys-table-keys
  ::
  ::  Base data comes from +schema.tables and the cache-time +data.files in
  ::  server-state-2.  +populate-system-view walks file keys, looks up each
  ::  matching +table, then +sys-view-table-keys enumerates the primary index
  ::  key columns from +table.pri-indx with one-based ordinals.
  ::
  ::  The view body is a %crud-txn query over db.sys.table-keys.  It exposes
  ::  columns: namespace, name, key-ordinal, key, key-ascending.
  ::
  ::  Orders by namespace, name, then key-ordinal ascending.
  |=  [db=@tas provenance=path tmsp=@da]
  ^-  view
  =/  columns=(list column:ast)
        %-  addr-columns  :~  [%column %namespace ~.tas 0]
                              [%column %name ~.tas 0]
                              [%column %key-ordinal ~.ud 0]
                              [%column %key ~.tas 0]
                              [%column %key-ascending ~.f 0]
                              ==
  :*  %view
      provenance                            ::provenance=path
      tmsp                                  ::tmsp=@da
      :+  %crud-txn                        ::crud-txn
          ~                                   ::ctes=(list cte)
          [%query (sys-table-keys-query db)]  ::query
      (malt (spun columns mk-col-lu-data))  ::column-lookup
      %-  malt
        %+  turn  columns
                  |=(a=column:ast [name.a [type.a addr.a]])  ::typ-addr-lookup
      columns                               ::columns=(list column)
      ~                                     ::ordering=(list column-order)
      ~                                     ::indices
      ~                                     ::references
      %.y                                   ::cacheable
      ''                                    ::text
      ==
++  sys-table-keys-query
  |=  database=@tas
  ^-  query:ast
  :*  %query
          :-  ~            ::from=(unit from)
              :^  %from
                  :*  %qualified-table  ::relation
                      ~
                      database
                      %sys
                      %table-keys
                      ~                    ::alias=(unit @t)
                      ==
                  ~  ::(unit as-of)
                  ~  ::joins=(list joined-relatation)
          ~  ::scalars=(list scalar-function)
          ~  ::=predicate
          ~  ::group-by=(list grouping-column)
          ~  ::having=predicate
          :+  %select  ::=select
              ~               ::top=(unit @ud)
              :~  :^  %qualified-column    ::qualified-column
                      :*  %qualified-table  ::qualifier
                          ~                    ::ship=(unit @p)
                          database             ::database=@tas
                          %sys                 ::namespace=@tas
                          %tables              ::name=@tas
                          ~                    ::alias=(unit @t)
                          ==
                      %namespace             ::column=@tas
                      `%namespace            ::alias=(unit @t)
                  :^  %qualified-column    ::qualified-column
                      :*  %qualified-table  ::qualifier
                          ~                    ::ship=(unit @p)
                          database             ::database=@tas
                          %sys                 ::namespace=@tas
                          %tables              ::name=@tas
                          ~                    ::alias=(unit @t)
                          ==
                      %name                  ::column=@tas
                      `%name                 ::alias=(unit @t)
                  :^  %qualified-column    ::qualified-column
                      :*  %qualified-table  ::qualifier
                          ~                    ::ship=(unit @p)
                          database             ::database=@tas
                          %sys                 ::namespace=@tas
                          %tables              ::name=@tas
                          ~                    ::alias=(unit @t)
                          ==
                      %key-ordinal           ::column=@tas
                      `%key-ordinal          ::alias=(unit @t)
                  :^  %qualified-column    ::qualified-column
                      :*  %qualified-table  ::qualifier
                          ~                    ::ship=(unit @p)
                          database             ::database=@tas
                          %sys                 ::namespace=@tas
                          %tables              ::name=@tas
                          ~                    ::alias=(unit @t)
                          ==
                      %key                   ::column=@tas
                      `%key                  ::alias=(unit @t)
                  :^  %qualified-column    ::qualified-column
                      :*  %qualified-table  ::qualifier
                          ~                    ::ship=(unit @p)
                          database             ::database=@tas
                          %sys                 ::namespace=@tas
                          %tables              ::name=@tas
                          ~                    ::alias=(unit @t)
                          ==
                      %key-ascending         ::column=@tas
                      `%key-ascending        ::alias=(unit @t)
                  ==
          :~      ::order-by=(list ordering-column)
              :+  %ordering-column
                  :^  %qualified-column    ::qualified-column
                  :*  %qualified-table  ::qualifier
                      ~           ::ship=(unit @p)
                      database    ::database=@tas
                      %sys        ::namespace=@tas
                      %tables     ::name=@tas
                      ~                    ::alias=(unit @t)
                      ==
                  %namespace  ::column=@tas
                  ~  ::alias=(unit @t)
                  %.y  ::ascending=?
              :+  %ordering-column
                  :^  %qualified-column    ::qualified-column
                  :*  %qualified-table  ::qualifier
                      ~           ::ship=(unit @p)
                      database    ::database=@tas
                      %sys        ::namespace=@tas
                      %tables     ::name=@tas
                      ~                    ::alias=(unit @t)
                      ==
                  %name      ::column=@tas
                  ~  ::alias=(unit @t)
                  %.y  ::ascending=?
              :+  %ordering-column
                  :^  %qualified-column    ::qualified-column
                  :*  %qualified-table  ::qualifier
                      ~           ::ship=(unit @p)
                      database    ::database=@tas
                      %sys        ::namespace=@tas
                      %tables      ::name=@tas
                      ~                    ::alias=(unit @t)
                      ==
                  %key-ordinal  ::column=@tas
                  ~  ::alias=(unit @t)
                  %.y  ::ascending=?
              ==
          ==
::
++  sys-foreign-keys-view
  ::  view name: sys-foreign-keys
  ::
  ::  Base data comes from canonical parent-side +foreign-constraints on
  ::  +file values.  +populate-system-view enumerates declared FKs and emits
  ::  one row for each parent/child column pair in FK ordinal order.
  ::
  ::  The view body is a %crud-txn query over db.sys.foreign-keys.  It exposes
  ::  columns: parent-namespace, parent-table, child-namespace, child-table,
  ::  ordinal, parent-column, child-column, on-delete, on-update.
  ::
  ::  Orders by parent-namespace, parent-table, child-namespace, child-table,
  ::  then ordinal ascending.
  |=  [db=@tas provenance=path tmsp=@da]
  ^-  view
  =/  columns=(list column:ast)
        %-  addr-columns  :~  [%column %parent-namespace ~.tas 0]
                              [%column %parent-table ~.tas 0]
                              [%column %child-namespace ~.tas 0]
                              [%column %child-table ~.tas 0]
                              [%column %ordinal ~.ud 0]
                              [%column %parent-column ~.tas 0]
                              [%column %child-column ~.tas 0]
                              [%column %on-delete ~.tas 0]
                              [%column %on-update ~.tas 0]
                              ==
  :*  %view
      provenance                              ::provenance=path
      tmsp                                    ::tmsp=@da
      :+  %crud-txn                          ::crud-txn
          ~                                     ::ctes=(list cte)
          [%query (sys-foreign-keys-query db)]  ::query
      (malt (spun columns mk-col-lu-data))    ::column-lookup
      %-  malt
        %+  turn  columns
                  |=(a=column:ast [name.a [type.a addr.a]])  ::typ-addr-lookup
      columns                                 ::columns=(list column)
      ~                                       ::ordering=(list column-order)
      ~                                       ::indices
      ~                                     ::references
      %.y                                   ::cacheable
      ''                                    ::text
      ==
++  sys-foreign-keys-query
  |=  database=@tas
  ^-  query:ast
  :*  %query
          :-  ~          ::from=(unit from)
              :^  %from
                  :*  %qualified-table  ::relation
                      ~
                      database
                      %sys
                      %foreign-keys
                      ~                    ::alias=(unit @t)
                      ==
                  ~  ::(unit as-of)
                  ~  ::joins=(list joined-relatation)
          ~  ::scalars=(list scalar-function)
          ~  ::=predicate
          ~  ::group-by=(list grouping-column)
          ~  ::having=predicate
          :+  %select  ::=select
              ~               ::top=(unit @ud)
              :~  :^  %qualified-column    ::qualified-column
                      :*  %qualified-table  ::qualifier
                          ~                    ::ship=(unit @p)
                          database             ::database=@tas
                          %sys                 ::namespace=@tas
                          %foreign-keys        ::name=@tas
                          ~                    ::alias=(unit @t)
                          ==
                      %parent-namespace      ::column=@tas
                      `%parent-namespace     ::alias=(unit @t)
                  :^  %qualified-column    ::qualified-column
                      :*  %qualified-table  ::qualifier
                          ~                    ::ship=(unit @p)
                          database             ::database=@tas
                          %sys                 ::namespace=@tas
                          %foreign-keys        ::name=@tas
                          ~                    ::alias=(unit @t)
                          ==
                      %parent-table          ::column=@tas
                      `%parent-table         ::alias=(unit @t)
                  :^  %qualified-column    ::qualified-column
                      :*  %qualified-table  ::qualifier
                          ~                    ::ship=(unit @p)
                          database             ::database=@tas
                          %sys                 ::namespace=@tas
                          %foreign-keys        ::name=@tas
                          ~                    ::alias=(unit @t)
                          ==
                      %child-namespace       ::column=@tas
                      `%child-namespace      ::alias=(unit @t)
                  :^  %qualified-column    ::qualified-column
                      :*  %qualified-table  ::qualifier
                          ~                    ::ship=(unit @p)
                          database             ::database=@tas
                          %sys                 ::namespace=@tas
                          %foreign-keys        ::name=@tas
                          ~                    ::alias=(unit @t)
                          ==
                      %child-table           ::column=@tas
                      `%child-table          ::alias=(unit @t)
                  :^  %qualified-column    ::qualified-column
                      :*  %qualified-table  ::qualifier
                          ~                    ::ship=(unit @p)
                          database             ::database=@tas
                          %sys                 ::namespace=@tas
                          %foreign-keys        ::name=@tas
                          ~                    ::alias=(unit @t)
                          ==
                      %ordinal               ::column=@tas
                      `%ordinal              ::alias=(unit @t)
                  :^  %qualified-column    ::qualified-column
                      :*  %qualified-table  ::qualifier
                          ~                    ::ship=(unit @p)
                          database             ::database=@tas
                          %sys                 ::namespace=@tas
                          %foreign-keys        ::name=@tas
                          ~                    ::alias=(unit @t)
                          ==
                      %parent-column         ::column=@tas
                      `%parent-column        ::alias=(unit @t)
                  :^  %qualified-column    ::qualified-column
                      :*  %qualified-table  ::qualifier
                          ~                    ::ship=(unit @p)
                          database             ::database=@tas
                          %sys                 ::namespace=@tas
                          %foreign-keys        ::name=@tas
                          ~                    ::alias=(unit @t)
                          ==
                      %child-column          ::column=@tas
                      `%child-column         ::alias=(unit @t)
                  :^  %qualified-column    ::qualified-column
                      :*  %qualified-table  ::qualifier
                          ~                    ::ship=(unit @p)
                          database             ::database=@tas
                          %sys                 ::namespace=@tas
                          %foreign-keys        ::name=@tas
                          ~                    ::alias=(unit @t)
                          ==
                      %on-delete             ::column=@tas
                      `%on-delete            ::alias=(unit @t)
                  :^  %qualified-column    ::qualified-column
                      :*  %qualified-table  ::qualifier
                          ~                    ::ship=(unit @p)
                          database             ::database=@tas
                          %sys                 ::namespace=@tas
                          %foreign-keys        ::name=@tas
                          ~                    ::alias=(unit @t)
                          ==
                      %on-update             ::column=@tas
                      `%on-update            ::alias=(unit @t)
                  ==
          :~      ::order-by=(list ordering-column)
              :+  %ordering-column
                  :^  %qualified-column    ::qualified-column
                  :*  %qualified-table  ::qualifier
                      ~           ::ship=(unit @p)
                      database    ::database=@tas
                      %sys        ::namespace=@tas
                      %foreign-keys  ::name=@tas
                      ~                    ::alias=(unit @t)
                      ==
                  %parent-namespace  ::column=@tas
                  ~  ::alias=(unit @t)
                  %.y  ::ascending=?
              :+  %ordering-column
                  :^  %qualified-column    ::qualified-column
                  :*  %qualified-table  ::qualifier
                      ~           ::ship=(unit @p)
                      database    ::database=@tas
                      %sys        ::namespace=@tas
                      %foreign-keys  ::name=@tas
                      ~                    ::alias=(unit @t)
                      ==
                  %parent-table  ::column=@tas
                  ~  ::alias=(unit @t)
                  %.y  ::ascending=?
              :+  %ordering-column
                  :^  %qualified-column    ::qualified-column
                  :*  %qualified-table  ::qualifier
                      ~           ::ship=(unit @p)
                      database    ::database=@tas
                      %sys        ::namespace=@tas
                      %foreign-keys  ::name=@tas
                      ~                    ::alias=(unit @t)
                      ==
                  %child-namespace  ::column=@tas
                  ~  ::alias=(unit @t)
                  %.y  ::ascending=?
              :+  %ordering-column
                  :^  %qualified-column    ::qualified-column
                  :*  %qualified-table  ::qualifier
                      ~           ::ship=(unit @p)
                      database    ::database=@tas
                      %sys        ::namespace=@tas
                      %foreign-keys  ::name=@tas
                      ~                    ::alias=(unit @t)
                      ==
                  %child-table  ::column=@tas
                  ~  ::alias=(unit @t)
                  %.y  ::ascending=?
              :+  %ordering-column
                  :^  %qualified-column    ::qualified-column
                  :*  %qualified-table  ::qualifier
                      ~           ::ship=(unit @p)
                      database    ::database=@tas
                      %sys        ::namespace=@tas
                      %foreign-keys  ::name=@tas
                      ~                    ::alias=(unit @t)
                      ==
                  %ordinal  ::column=@tas
                  ~  ::alias=(unit @t)
                  %.y  ::ascending=?
              ==
          ==
::
++  sys-columns-view
  ::  view name: sys-columns
  ::
  ::  Base data comes from +schema.tables, the cache-time +data.files, and
  ::  +schema.views in server-state-2.  +populate-system-view walks file keys,
  ::  looks up each matching +table, then +sys-view-columns enumerates
  ::  +table.columns with one-based ordinals; +sys-view-view-columns does the
  ::  same for each user-defined view.
  ::
  ::  The view body is a %crud-txn query over db.sys.columns.  It exposes
  ::  columns: namespace, name, relation-type, col-ordinal, col-name,
  ::  col-type.  relation-type is %table or %view.
  ::
  ::  Orders by namespace, name, then col-ordinal ascending.
  |=  [db=@tas provenance=path tmsp=@da]
  ^-  view
  %:  mk-sys-view  db
                   %columns
                   provenance
                   tmsp
                   :~  [%column %namespace ~.tas 0]
                       [%column %name ~.tas 0]
                       [%column %relation-type ~.tas 0]
                       [%column %col-ordinal ~.ud 0]
                       [%column %col-name ~.tas 0]
                       [%column %col-type ~.ta 0]
                       ==
                   ~[%namespace %name %col-ordinal]
                   ==
::
++  sys-views-view
  ::  view name: sys-views
  ::
  ::  Base data comes from the user-defined views of +schema.views in
  ::  server-state-2, those not in namespace sys.
  ::
  ::  The view body is a %crud-txn query over db.sys.views.  It exposes
  ::  columns: namespace, name, agent, tmsp, cacheable, definition.  agent
  ::  is the view provenance path rendered as text; definition is the view
  ::  query source text.
  ::
  ::  Orders by namespace, then name ascending.
  |=  [db=@tas provenance=path tmsp=@da]
  ^-  view
  %:  mk-sys-view  db
                   %views
                   provenance
                   tmsp
                   :~  [%column %namespace ~.tas 0]
                       [%column %name ~.tas 0]
                       [%column %agent ~.ta 0]
                       [%column %tmsp ~.da 0]
                       [%column %cacheable ~.f 0]
                       [%column %definition ~.t 0]
                       ==
                   ~[%namespace %name]
                   ==
::
++  sys-view-references-view
  ::  view name: sys-view-references
  ::
  ::  Base data comes from +view.references of the user-defined views of
  ::  +schema.views in server-state-2.
  ::
  ::  The view body is a %crud-txn query over db.sys.view-references.  It
  ::  exposes columns: namespace, name, ref-namespace, ref-name, ref-type.
  ::  ref-type is %table or %view.
  ::
  ::  Orders by namespace, name, ref-namespace, then ref-name ascending.
  |=  [db=@tas provenance=path tmsp=@da]
  ^-  view
  %:  mk-sys-view  db
                   %view-references
                   provenance
                   tmsp
                   :~  [%column %namespace ~.tas 0]
                       [%column %name ~.tas 0]
                       [%column %ref-namespace ~.tas 0]
                       [%column %ref-name ~.tas 0]
                       [%column %ref-type ~.tas 0]
                       ==
                   ~[%namespace %name %ref-namespace %ref-name]
                   ==
::
++  database-sys-views
  ::  the system views of user database db, keyed at tmsp
  |=  [db=@tas provenance=path tmsp=@da]
  ^-  (list [ns-rel-key view])
  :~  [[%sys %namespaces tmsp] (sys-namespaces-view db provenance tmsp)]
      [[%sys %tables tmsp] (sys-tables-view db provenance tmsp)]
      [[%sys %table-keys tmsp] (sys-table-keys-view db provenance tmsp)]
      [[%sys %foreign-keys tmsp] (sys-foreign-keys-view db provenance tmsp)]
      [[%sys %columns tmsp] (sys-columns-view db provenance tmsp)]
      [[%sys %views tmsp] (sys-views-view db provenance tmsp)]
      :-  [%sys %view-references tmsp]
          (sys-view-references-view db provenance tmsp)
      [[%sys %sys-log tmsp] (sys-sys-log-view db provenance tmsp)]
      [[%sys %data-log tmsp] (sys-data-log-view db provenance tmsp)]
      ==
::
++  mk-sys-view
  ::  system view over db.sys.<name> of columns, ordered ascending by keys
  |=  $:  db=@tas
          name=@tas
          provenance=path
          tmsp=@da
          columns=(list column:ast)
          keys=(list @tas)
          ==
  ^-  view
  =/  addressed=(list column:ast)  (addr-columns columns)
  =/  qt=qualified-table:ast  [%qualified-table ~ db %sys name ~]
  =/  selected=(list selected-column:ast)
    %+  turn  addressed
    |=(c=column:ast [%qualified-column qt name.c `name.c])
  =/  order-by=(list ordering-column:ast)
    %+  turn  keys
    |=(k=@tas [%ordering-column [%qualified-column qt k ~] %.y])
  =/  =query:ast
    [%query `[%from qt ~ ~] ~ ~ ~ ~ [%select ~ selected] order-by]
  :*  %view
      provenance
      tmsp
      [%crud-txn ~ [%query query]]
      (malt (spun addressed mk-col-lu-data))
      (malt (turn addressed |=(a=column:ast [name.a [type.a addr.a]])))
      addressed
      ~
      ~
      ~
      %.y
      ''
      ==
::
++  sys-sys-log-view
  ::  view name: sys-sys-log
  ::
  ::  Base data comes from +database.event-log in server-state-2.
  ::
  ::  The view body is a %crud-txn query over db.sys.sys-log.  It exposes the
  ::  complete persisted event: tmsp, agent, action, component, database,
  ::  namespace, name, target-database, target-namespace, target-relation, 
  ::  message.
  ::  agent is the schema provenance path rendered as text.
  ::
  ::  Orders by component, database, namespace, relation, and tmsp ascending.
  |=  [database=@tas provenance=path tmsp=@da]
  ^-  view
  =/  columns=(list column:ast)
        %-  addr-columns  :~  [%column %tmsp ~.da 0]
                              [%column %agent ~.ta 0]
                              [%column %action ~.tas 0]
                              [%column %component ~.tas 0]
                              [%column %database ~.tas 0]
                              [%column %namespace ~.tas 0]
                              [%column %relation-id ~.tas 0]
                              [%column %target-database ~.tas 0]
                              [%column %target-namespace ~.tas 0]
                              [%column %target-relation ~.tas 0]
                              [%column %message ~.t 0]
                              ==
  :*  %view
      provenance                            ::provenance=path
      tmsp                                  ::tmsp=@da
      :+  %crud-txn                        ::crud-txn
          ~                                   ::ctes=(list cte)
          [%query (sys-sys-log-query database)]  ::query
      (malt (spun columns mk-col-lu-data))  ::column-lookup
      %-  malt
        %+  turn  columns
                  |=(a=column:ast [name.a [type.a addr.a]])  ::typ-addr-lookup
      columns                               ::columns=(list column)
      ~                                     ::ordering=(list column-order)
      ~                                     ::indices
      ~                                     ::references
      %.y                                   ::cacheable
      ''                                    ::text
      ==
++  sys-sys-log-query
  |=  database=@tas
  ^-  query:ast
  :*  %query
          :-  ~            ::from=(unit from)
              :^  %from
                  :*  %qualified-table  ::relation
                      ~
                      database
                      %sys
                      %sys-log
                      ~                    ::alias=(unit @t)
                      ==
                  ~  ::(unit as-of)
                  ~  ::joins=(list joined-relatation)
          ~  ::scalars=(list scalar-function)
          ~  ::=predicate
          ~  ::group-by=(list grouping-column)
          ~  ::having=predicate
          :+  %select  ::=select
              ~               ::top=(unit @ud)
              :~  :^  %qualified-column    ::qualified-column
                      :*  %qualified-table  ::qualifier
                          ~                    ::ship=(unit @p)
                          database             ::database=@tas
                          %sys                 ::namespace=@tas
                          %sys-log             ::name=@tas
                          ~                    ::alias=(unit @t)
                          ==
                      %tmsp                  ::column=@tas
                      `%tmsp                 ::alias=(unit @t)
                  :^  %qualified-column    ::qualified-column
                      :*  %qualified-table  ::qualifier
                          ~                    ::ship=(unit @p)
                          database             ::database=@tas
                          %sys                 ::namespace=@tas
                          %sys-log             ::name=@tas
                          ~                    ::alias=(unit @t)
                          ==
                      %agent                 ::column=@tas
                      `%agent                ::alias=(unit @t)
                  :^  %qualified-column    ::qualified-column
                      :*  %qualified-table  ::qualifier
                          ~                    ::ship=(unit @p)
                          database             ::database=@tas
                          %sys                 ::namespace=@tas
                          %sys-log             ::name=@tas
                          ~                    ::alias=(unit @t)
                          ==
                      %action                ::column=@tas
                      `%action               ::alias=(unit @t)
                  :^  %qualified-column    ::qualified-column
                      :*  %qualified-table  ::qualifier
                          ~                    ::ship=(unit @p)
                          database             ::database=@tas
                          %sys                 ::namespace=@tas
                          %sys-log             ::name=@tas
                          ~                    ::alias=(unit @t)
                          ==
                      %component             ::column=@tas
                      `%component            ::alias=(unit @t)
                  :^  %qualified-column    ::qualified-column
                      :*  %qualified-table  ::qualifier
                          ~                    ::ship=(unit @p)
                          database             ::database=@tas
                          %sys                 ::namespace=@tas
                          %sys-log             ::name=@tas
                          ~                    ::alias=(unit @t)
                          ==
                      %database              ::column=@tas
                      `%database             ::alias=(unit @t)
                  :^  %qualified-column    ::qualified-column
                      :*  %qualified-table  ::qualifier
                          ~                    ::ship=(unit @p)
                          database             ::database=@tas
                          %sys                 ::namespace=@tas
                          %sys-log             ::name=@tas
                          ~                    ::alias=(unit @t)
                          ==
                      %namespace             ::column=@tas
                      `%namespace            ::alias=(unit @t)
                  :^  %qualified-column    ::qualified-column
                      :*  %qualified-table  ::qualifier
                          ~                    ::ship=(unit @p)
                          database             ::database=@tas
                          %sys                 ::namespace=@tas
                          %sys-log             ::name=@tas
                          ~                    ::alias=(unit @t)
                          ==
                      %name                  ::column=@tas
                      `%name                 ::alias=(unit @t)
                  :^  %qualified-column    ::qualified-column
                      :*  %qualified-table  ::qualifier
                          ~                    ::ship=(unit @p)
                          database             ::database=@tas
                          %sys                 ::namespace=@tas
                          %sys-log             ::name=@tas
                          ~                    ::alias=(unit @t)
                          ==
                      %target-database       ::column=@tas
                      `%target-database      ::alias=(unit @t)
                  :^  %qualified-column    ::qualified-column
                      :*  %qualified-table  ::qualifier
                          ~                    ::ship=(unit @p)
                          database             ::database=@tas
                          %sys                 ::namespace=@tas
                          %sys-log             ::name=@tas
                          ~                    ::alias=(unit @t)
                          ==
                      %target-namespace      ::column=@tas
                      `%target-namespace     ::alias=(unit @t)
                  :^  %qualified-column    ::qualified-column
                      :*  %qualified-table  ::qualifier
                          ~                    ::ship=(unit @p)
                          database             ::database=@tas
                          %sys                 ::namespace=@tas
                          %sys-log             ::name=@tas
                          ~                    ::alias=(unit @t)
                          ==
                      %target-relation           ::column=@tas
                      `%target-relation          ::alias=(unit @t)
                  :^  %qualified-column    ::qualified-column
                      :*  %qualified-table  ::qualifier
                          ~                    ::ship=(unit @p)
                          database             ::database=@tas
                          %sys                 ::namespace=@tas
                          %sys-log             ::name=@tas
                          ~                    ::alias=(unit @t)
                          ==
                      %message               ::column=@tas
                      `%message              ::alias=(unit @t)
                  ==
          :~      ::order-by=(list ordering-column)
              :+  %ordering-column
                  :^  %qualified-column    ::qualified-column
                  :*  %qualified-table  ::qualifier
                      ~           ::ship=(unit @p)
                      database    ::database=@tas
                      %sys        ::namespace=@tas
                      %sys-log    ::name=@tas
                      ~                    ::alias=(unit @t)
                      ==
                  %component      ::column=@tas
                  ~  ::alias=(unit @t)
                  %.y  ::ascending=?
              :+  %ordering-column
                  :^  %qualified-column    ::qualified-column
                  :*  %qualified-table  ::qualifier
                      ~           ::ship=(unit @p)
                      database    ::database=@tas
                      %sys        ::namespace=@tas
                      %sys-log    ::name=@tas
                      ~                    ::alias=(unit @t)
                      ==
                  %database       ::column=@tas
                  ~  ::alias=(unit @t)
                  %.y  ::ascending=?
              :+  %ordering-column
                  :^  %qualified-column    ::qualified-column
                  :*  %qualified-table  ::qualifier
                      ~           ::ship=(unit @p)
                      database    ::database=@tas
                      %sys        ::namespace=@tas
                      %sys-log    ::name=@tas
                      ~                    ::alias=(unit @t)
                      ==
                  %namespace      ::column=@tas
                  ~  ::alias=(unit @t)
                  %.y  ::ascending=?
              :+  %ordering-column
                  :^  %qualified-column    ::qualified-column
                  :*  %qualified-table  ::qualifier
                      ~           ::ship=(unit @p)
                      database    ::database=@tas
                      %sys        ::namespace=@tas
                      %sys-log    ::name=@tas
                      ~                    ::alias=(unit @t)
                      ==
                  %relation-id  ::column=@tas
                  ~  ::alias=(unit @t)
                  %.y  ::ascending=?
              :+  %ordering-column
                  :^  %qualified-column    ::qualified-column
                  :*  %qualified-table  ::qualifier
                      ~           ::ship=(unit @p)
                      database    ::database=@tas
                      %sys        ::namespace=@tas
                      %sys-log    ::name=@tas
                      ~                    ::alias=(unit @t)
                      ==
                  %tmsp          ::column=@tas
                  ~  ::alias=(unit @t)
                  %.y  ::ascending=?
              ==
          ==
::
++  sys-data-log-view
  ::  view name: sys-data-log
  ::
  ::  Base data comes from the full +database.content data history in
  ::  server-state-2.  +populate-system-view walks every +data snapshot, and
  ::  +sys-view-data-log emits file rows whose +file.tmsp equals that data
  ::  snapshot timestamp.
  ::
  ::  The view body is a %crud-txn query over db.sys.data-log.  It exposes
  ::  columns: tmsp, ship, agent, namespace, table, row-count.  ship and agent
  ::  come from +data.ship and +data.provenance; row-count comes from +file.
  ::
  ::  Orders by tmsp descending, then namespace and table ascending.
  |=  [database=@tas provenance=path tmsp=@da]
  ^-  view
  =/  columns=(list column:ast)
        %-  addr-columns  :~  [%column %tmsp ~.da 0]
                              [%column %ship ~.p 0]
                              [%column %agent ~.ta 0]
                              [%column %namespace ~.tas 0]
                              [%column %table ~.tas 0]
                              [%column %row-count ~.ud 0]
                              ==
  :*  %view
      provenance                            ::provenance=path
      tmsp                                  ::tmsp=@da
      :+  %crud-txn                        ::crud-txn
          ~                                   ::ctes=(list cte)
          [%query (sys-data-log-query database)]  ::query
      (malt (spun columns mk-col-lu-data))  ::column-lookup
      %-  malt
        %+  turn  columns
                  |=(a=column:ast [name.a [type.a addr.a]])  ::typ-addr-lookup
      columns                               ::columns=(list column)
      ~                                     ::ordering=(list column-order)
      ~                                     ::indices
      ~                                     ::references
      %.y                                   ::cacheable
      ''                                    ::text
      ==
++  sys-data-log-query
  |=  database=@tas
  ^-  query:ast
  :*  %query
          :-  ~           ::from=(unit from)
              :^  %from
                  :*  %qualified-table  ::relation
                      ~
                      database
                      %sys
                      %data-log
                      ~                    ::alias=(unit @t)
                      ==
                  ~       ::(unit as-of)
                  ~       ::joins=(list joined-relatation)
          ~   ::scalars=(list scalar-function)
          ~   ::=predicate
          ~   ::group-by=(list grouping-column)
          ~   ::having=predicate
          :+  %select  ::=select
              ~               ::top=(unit @ud)
              :~  :^  %qualified-column    ::qualified-column
                      :*  %qualified-table  ::qualifier
                          ~                    ::ship=(unit @p)
                          database             ::database=@tas
                          %sys                 ::namespace=@tas
                          %data-log            ::name=@tas
                          ~                    ::alias=(unit @t)
                          ==
                      %tmsp                  ::column=@tas
                      `%tmsp                 ::alias=(unit @t)
                  :^  %qualified-column    ::qualified-column
                      :*  %qualified-table  ::qualifier
                          ~                    ::ship=(unit @p)
                          database             ::database=@tas
                          %sys                 ::namespace=@tas
                          %data-log            ::name=@tas
                          ~                    ::alias=(unit @t)
                          ==
                      %ship                ::column=@tas
                      `%ship               ::alias=(unit @t)
                  :^  %qualified-column    ::qualified-column
                      :*  %qualified-table  ::qualifier
                          ~                  ::ship=(unit @p)
                          database           ::database=@tas
                          %sys               ::namespace=@tas
                          %data-log           ::name=@tas
                          ~                    ::alias=(unit @t)
                          ==
                      %agent               ::column=@tas
                      `%agent              ::alias=(unit @t)
                  :^  %qualified-column    ::qualified-column
                      :*  %qualified-table  ::qualifier
                          ~                    ::ship=(unit @p)
                          database             ::database=@tas
                          %sys                 ::namespace=@tas
                          %data-log            ::name=@tas
                          ~                    ::alias=(unit @t)
                          ==
                      %namespace             ::column=@tas
                      `%namespace            ::alias=(unit @t)
                  :^  %qualified-column    ::qualified-column
                      :*  %qualified-table  ::qualifier
                          ~                    ::ship=(unit @p)
                          database             ::database=@tas
                          %sys                 ::namespace=@tas
                          %data-log            ::name=@tas
                          ~                    ::alias=(unit @t)
                          ==
                      %table                 ::column=@tas
                      `%table                ::alias=(unit @t)
                  :^  %qualified-column    ::qualified-column
                      :*  %qualified-table  ::qualifier
                          ~                    ::ship=(unit @p)
                          database             ::database=@tas
                          %sys                 ::namespace=@tas
                          %data-log            ::name=@tas
                          ~                    ::alias=(unit @t)
                          ==
                      %row-count             ::column=@tas
                      `%row-count            ::alias=(unit @t)
                  ==
          :~      ::order-by=(list ordering-column)
              :+  %ordering-column
                  :^  %qualified-column    ::qualified-column
                  :*  %qualified-table  ::qualifier
                      ~                    ::ship=(unit @p)
                      database             ::database=@tas
                      %sys                 ::namespace=@tas
                      %data-log            ::name=@tas
                      ~                    ::alias=(unit @t)
                      ==
                  %tmsp                  ::column=@tas
                  ~                      ::alias=(unit @t)
                  %.n                    ::ascending=?
              :+  %ordering-column
                  :^  %qualified-column    ::qualified-column
                  :*  %qualified-table  ::qualifier
                      ~                    ::ship=(unit @p)
                      database             ::database=@tas
                      %sys                 ::namespace=@tas
                      %data-log            ::name=@tas
                      ~                    ::alias=(unit @t)
                      ==
                  %namespace             ::column=@tas
                  ~                      ::alias=(unit @t)
                  %.y                    ::ascending=?
              :+  %ordering-column
                  :^  %qualified-column    ::qualified-column
                  :*  %qualified-table  ::qualifier
                      ~                    ::ship=(unit @p)
                      database             ::database=@tas
                      %sys                 ::namespace=@tas
                      %data-log            ::name=@tas
                      ~                    ::alias=(unit @t)
                      ==
                  %table  ::column=@tas
                  ~       ::alias=(unit @t)
                  %.y     ::ascending=?
              ==
          ==
::
++  view-row-order
  ::  Comparator of raw view rows by the ORDER BY of the view query, by the
  ::  aura of each column.  Inverse, since +atoms-2-mapped-row reverses the
  ::  rows.  An ORDER BY column that is not a view column is ignored.
  ::
  ::  The ordering of a view is computed here; the ordering field of a view
  ::  is no longer set or read.
  |=  =view
  ^-  $-([(list @) (list @)] ?)
  =/  order-by=(list ordering-column:ast)
    ?.  ?=([%query *] body.crud-txn.view)  ~
    =/  q=query:ast  +.body.crud-txn.view
    order-by.q
  =/  names=(list @tas)  (turn columns.view |=(c=column:ast name.c))
  =/  keys=(list [aura=@ta ascending=? offset=@ud])
    %+  murn  order-by
    |=  oc=ordering-column:ast
    ^-  (unit [@ta ? @ud])
    ?.  ?=(qualified-column:ast column.oc)
      ~|("view order column error:  {<column.oc>}" !!)
    =/  at  (find ~[name.column.oc] names)
    ?~  at  ~
    `[type:(snag u.at columns.view) ascending.oc u.at]
  =/  ascending=(list ?)  (turn keys |=([* a=? *] a))
  =/  key
    |=  row=(list @)
    ^-  (list (unit [p=@ta q=@]))
    (turn keys |=([a=@ta * o=@ud] `[a (snag o row)]))
  |=  [p=(list @) q=(list @)]
  ^-  ?
  (key-before ascending (key q) (key p))
::
++  populate-system-view
  ::  Side effect: populate view-cache
  ::               theoretically a state change, but referentially transparent
  |=  [=server =database =schema =view name=@tas cache-time=@da]
  ^-  [@ (list (map @tas @))]
  ?+  name  ~|("unknown system view" !!)
  ::
  %databases
    =/  dbes  %+  skim
                  ^-  (list (list @))
                      (zing (turn ~(val by server) sys-view-databases))
                  |=(a=(list @) (lte +>-.a cache-time))
    %+  atoms-2-mapped-row
          (sort dbes (view-row-order view))
          columns.view
  ::
  %namespaces
    =/  namespaces  (~(urn by namespaces.schema) |=([k=@tas v=@da] ~[k v]))
    =/  nses  %+  skim
                  `(list (list @))`~(val by namespaces)
                  |=(a=(list @) (lte +<.a cache-time))
    %+  atoms-2-mapped-row
          (sort nses (view-row-order view))
          columns.view
  ::
  %tables
    =/  udata=data  (get-data content.database cache-time)
    =/  tbls  %+  skim
                  ^-  (list (list @))
                      %-  zing
                          %+  turn  ~(tap by files.udata)
                                    ~(foo sys-view-tables tables.schema)
                  |=(a=(list @) (lte +>+<.a cache-time))                  
    %+  atoms-2-mapped-row
        (sort tbls (view-row-order view))
        columns.view
  ::
  %table-keys
    =/  udata=data  (get-data content.database cache-time)
    =/  table-keys  ^-  (list (list @))
                          %-  zing
                                  %+  turn  ~(tap by files.udata)
                                      ~(foo sys-view-table-keys tables.schema)
    %+  atoms-2-mapped-row
        (sort table-keys (view-row-order view))
        columns.view
  ::
  %foreign-keys
    =/  udata=data  (get-data content.database cache-time)
    =/  foreign-keys  ^-  (list (list @))
                            %-  zing
                                    %+  turn  ~(tap by files.udata)
                                        ~(foo sys-view-foreign-keys tables.schema)
    %+  atoms-2-mapped-row
        (sort foreign-keys (view-row-order view))
        columns.view
  ::
  %columns
    =/  udata=data  (get-data content.database cache-time)
    =/  columns  ^-  (list (list @))
                      %-  zing
                            %+  turn  ~(tap by files.udata)
                                ~(foo sys-view-columns tables.schema)
    =/  vw-columns=(list (list @))
      %-  zing
      %+  turn  (user-views views.schema cache-time)
      |=  [k=ns-rel-key v=_view]
      ^-  (list (list @))
      =/  numbered
        %^  spin  columns.v
            1
            |=([n=column:ast a=@] [`(list @)`~[a name.n type.n] +(a)])
      (turn p.numbered |=(a=(list @) (weld ~[ns.k rel.k %view] a)))
    =/  all-columns=(list (list @))  (weld columns vw-columns)
    %+  atoms-2-mapped-row
        (sort all-columns (view-row-order view))
        columns.view
  ::
  %views
    =/  rows=(list (list @))
      %+  turn  (user-views views.schema cache-time)
      |=  [k=ns-rel-key v=_view]
      ^-  (list @)
      ~[ns.k rel.k (crip (spud provenance.v)) tmsp.v cacheable.v text.v]
    %+  atoms-2-mapped-row
        (sort rows (view-row-order view))
        columns.view
  ::
  %view-references
    =/  rows=(list (list @))
      %-  zing
      %+  turn  (user-views views.schema cache-time)
      |=  [k=ns-rel-key v=_view]
      ^-  (list (list @))
      %+  turn  references.v
      |=(r=view-reference `(list @)`~[ns.k rel.k ns.r rel.r kind.r])
    %+  atoms-2-mapped-row
        (sort rows (view-row-order view))
        columns.view
  ::
  %sys-log
    =/  log   %+  skim
                  (turn event-log.database sys-view-sys-log-event)
                  |=(a=(list @) (lte -.a cache-time))
    %+  atoms-2-mapped-row
        (sort `(list (list @))`log (view-row-order view))
        columns.view
  ::
  %data-log
    =/  tbls  %+  skim
                  ^-  (list (list @))
                      %-  zing
                          %+  turn  %+  turn  (tap:data-key content.database)
                                              |=(b=[@da data] +.b)
                                    sys-view-data-log
                  |=(a=(list @) (lte -.a cache-time))
    %+  atoms-2-mapped-row
        (sort tbls (view-row-order view))
        columns.view
  ==
::
++  user-views
  ::  the user-defined views of a schema defined at or before time
  |=  [=views time=@da]
  ^-  (list [ns-rel-key view])
  %+  skim  (live-user-views views)
  |=([k=ns-rel-key *] (lte time.k time))
::
++  sys-view-databases
  |=  a=database
  ^-  (list (list @))
  =/  sys=(list schema)
        (flop (turn (tap:schema-key sys.a) |=(b=[@da schema] +.b)))
  =/  udata=(list data)
        (flop (turn (tap:data-key content.a) |=(b=[@da data] +.b)))
  =/  rslt  *(list (list @))
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
::
++  sys-view-tables
  |_  =tables
  ++  foo
    |=  [k=[@tas @tas] =file]
    ^-  (list (list @))
    =/  tbl  (~(got by tables) [-.k +.k])
    ~[~[-.k +.k (crip (spud provenance.tbl)) tmsp.tbl rowcount.file]]
  --
::
++  sys-view-table-keys
  |_  =tables
  ++  foo
    |=  [k=[@tas @tas] =file]
    ^-  (list (list @))
    =/  aa=(list @)  :~  -.k
                        +.k
                          ==
    =/  tbl  (~(got by tables) [-.k +.k])
    =/  keys
      %^  spin  key.pri-indx.tbl
          1
          |=([n=key-column:ast a=@] [~[a name.n ascending.n] +(a)])
    (turn p.keys |=(a=(list @) (weld aa a)))
  --
::
++  sys-view-foreign-keys
  |_  =tables
  ++  foo
    |=  [parent-key=[@tas @tas] parent-file=file]
    ^-  (list (list @))
    =/  parent-tbl=table  (~(got by tables) parent-key)
    =/  parent-cols=(list @tas)
          (turn key.pri-indx.parent-tbl |=(k=key-column:ast name.k))
    =/  fks=(list foreign-constraint)  foreign-constraints.parent-file
    |-
    ?~  fks  ~
    =/  rows=(list (list @))
      %-  foreign-key-column-rows
      :*  parent-key
          constrained-table.i.fks
          parent-cols
          constrained-columns.i.fks
          actions.i.fks
          ==
    =/  rest=(list (list @))  $(fks t.fks)
    (weld rows rest)
  --
::
++  foreign-key-column-rows
  |=  $:  parent-key=[@tas @tas]
          child-key=[@tas @tas]
          parent-cols=(list @tas)
          child-cols=(list @tas)
          actions=constraints:ast
          ==
  ^-  (list (list @))
  =/  ordinal=@ud  1
  |-
  ?~  parent-cols
    ?~  child-cols  ~
    ~|("sys.foreign-keys: foreign key column mismatch" !!)
  ?~  child-cols
    ~|("sys.foreign-keys: foreign key column mismatch" !!)
  :-  :~  -.parent-key
          +.parent-key
          -.child-key
          +.child-key
          ordinal
          i.parent-cols
          i.child-cols
          on-delete.actions
          on-update.actions
          ==
  $(parent-cols t.parent-cols, child-cols t.child-cols, ordinal +(ordinal))
::
++  sys-view-columns
  |_  =tables
  ++  foo
    |=  [k=[@tas @tas] =file]
    ^-  (list (list @))
    =/  aa=(list @)  ~[-.k +.k %table]
    =/  tbl  (~(got by tables) [-.k +.k])
    =/  columns
      %^  spin  columns.tbl
          1
          |=([n=column:ast a=@] [`(list @)`~[a name.n type.n] +(a)])
    (turn p.columns |=(a=(list @) (weld aa a)))
    --
::
::
++  sys-view-sys-log-event
  |=  event=sys-log-event
  ^-  (list @)
  :~  tmsp.event
      (crip (spud provenance.event))
      action.event
      component.event
      database.event
      (unit-tas-text namespace.event)
      (unit-tas-text relation.event)
      (unit-tas-text target-database.event)
      (unit-tas-text target-namespace.event)
      (unit-tas-text target-relation.event)
      (unit-text message.event)
      ==
::
++  unit-tas-text
  |=  value=(unit @tas)
  ^-  @t
  ?~  value  ''
  `@t`u.value
::
++  unit-text
  |=  value=(unit @t)
  ^-  @t
  ?~  value  ''
  u.value
::
++  sys-view-data-log
  |=  a=data
  ^-  (list (list @))
  =/  tbls  %+  skim
                %~  val  by
                    (~(urn by files.a) |=([k=[@tas @tas] =file] [k file]))
                |=(b=[k=[@tas @tas] =file] =(tmsp.a tmsp.file.b))
  %+  turn  tbls  |=  [k=[@tas @tas] =file]
                  :~  tmsp.a
                      ship.a
                      (crip (spud provenance.a))
                      -.k
                      +.k
                      rowcount.file
                          ==
::
++  get-data
  |=  [sys=((mop @da data) gth) time=@da]
  ^-  data
  =/  exact  (get:data-key sys time)
  ?^  exact  (need exact)
  =/  prior  (pry:data-key (lot:data-key sys `time ~))
  ?~  prior  ~|("data not available for {<time>}" !!)
  +:(need prior)
::
++  atoms-2-mapped-row
  |=  [p=(list (list @)) q=(list column:ast)]
  ^-  [@ (list (map @tas @))]
  =/  rows  *(list (map @tas @))
  =/  i  0
  |-
  ?~  p  [i rows]
  $(i +(i), p +.p, rows [(malt (zip-columns -.p q)) rows])
::
++  zip-columns
  |*  [a=(list @) b=(list column:ast)]
  ^-  (list [@tas @])
  =/  c  *(list [@tas @])
  |-
  ?~  a  ?~  b  c  ~|('column lists of unequal length' !!)
  ?~  b  ~|('column lists of unequal length' !!)
  $(a +.a, b +.b, c [[name.i.b -.a] c])
--
