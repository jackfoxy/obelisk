/-  ast, *obelisk, *server-state-1
/+  *utils
|%
::
++  sys-sys-dbs-view
  ::  view name: sys-databases
  ::
  ::  Base data comes from the server map in server-state-1.  For each
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
  ::  Base data comes from +schema.namespaces in server-state-1, a map from
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
                  %tmsp  ::column=@tas
                  ~    ::alias=(unit @t)
                  %.y  ::ascending=?
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
  ::  server-state-1.  +populate-system-view selects the current +data with
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
  ::  server-state-1.  +populate-system-view walks file keys, looks up each
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
++  sys-columns-view
  ::  view name: sys-columns
  ::
  ::  Base data comes from +schema.tables and the cache-time +data.files in
  ::  server-state-1.  +populate-system-view walks file keys, looks up each
  ::  matching +table, then +sys-view-columns enumerates +table.columns with
  ::  one-based ordinals.
  ::
  ::  The view body is a %crud-txn query over db.sys.columns.  It exposes
  ::  columns: namespace, name, col-ordinal, col-name, col-type.
  ::
  ::  Orders by namespace, name, then col-ordinal ascending.
  |=  [db=@tas provenance=path tmsp=@da]
  ^-  view
  =/  columns=(list column:ast)
        %-  addr-columns  :~  [%column %namespace ~.tas 0]
                              [%column %name ~.tas 0]
                              [%column %col-ordinal ~.ud 0]
                              [%column %col-name ~.tas 0]
                              [%column %col-type ~.ta 0]
                              ==
  :*  %view
      provenance                            ::provenance=path
      tmsp                                  ::tmsp=@da
      :+  %crud-txn                        ::crud-txn
          ~                                   ::ctes=(list cte)
          [%query (sys-columns-query db)]     ::query
      (malt (spun columns mk-col-lu-data))  ::column-lookup
      %-  malt
        %+  turn  columns
                  |=(a=column:ast [name.a [type.a addr.a]])  ::typ-addr-lookup
      columns                               ::columns=(list column)
      ~                                     ::ordering=(list column-order)
      ~                                     ::indices
      ==
++  sys-columns-query
  |=  database=@tas
  ^-  query:ast
  :*  %query
          :-  ~          ::from=(unit from)
              :^  %from
                  :*  %qualified-table  ::relation
                      ~
                      database
                      %sys
                      %columns
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
                          %columns             ::name=@tas
                          ~                    ::alias=(unit @t)
                          ==
                      %namespace             ::column=@tas
                      `%namespace            ::alias=(unit @t)
                  :^  %qualified-column    ::qualified-column
                      :*  %qualified-table  ::qualifier
                          ~                    ::ship=(unit @p)
                          database             ::database=@tas
                          %sys                 ::namespace=@tas
                          %columns             ::name=@tas
                          ~                    ::alias=(unit @t)
                          ==
                      %name                  ::column=@tas
                      `%name                 ::alias=(unit @t)
                  :^  %qualified-column    ::qualified-column
                      :*  %qualified-table  ::qualifier
                          ~                    ::ship=(unit @p)
                          database             ::database=@tas
                          %sys                 ::namespace=@tas
                          %columns             ::name=@tas
                          ~                    ::alias=(unit @t)
                          ==
                      %col-ordinal           ::column=@tas
                      `%col-ordinal          ::alias=(unit @t)
                  :^  %qualified-column    ::qualified-column
                      :*  %qualified-table  ::qualifier
                          ~                    ::ship=(unit @p)
                          database             ::database=@tas
                          %sys                 ::namespace=@tas
                          %columns             ::name=@tas
                          ~                    ::alias=(unit @t)
                          ==
                      %col-name              ::column=@tas
                      `%col-name             ::alias=(unit @t)
                  :^  %qualified-column    ::qualified-column
                      :*  %qualified-table  ::qualifier
                          ~                    ::ship=(unit @p)
                          database             ::database=@tas
                          %sys                 ::namespace=@tas
                          %columns             ::name=@tas
                          ~                    ::alias=(unit @t)
                          ==
                      %col-type              ::column=@tas
                      `%col-type             ::alias=(unit @t)
                  ==
          :~      ::order-by=(list ordering-column)
              :+  %ordering-column
                  :^  %qualified-column    ::qualified-column
                  :*  %qualified-table  ::qualifier
                      ~           ::ship=(unit @p)
                      database    ::database=@tas
                      %sys        ::namespace=@tas
                      %columns    ::name=@tas
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
                      %columns    ::name=@tas
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
                      %columns  ::name=@tas
                      ~                    ::alias=(unit @t)
                      ==
                  %col-ordinal  ::column=@tas
                  ~  ::alias=(unit @t)
                  %.y  ::ascending=?
              ==
          ==
::
++  sys-sys-log-view
  ::  view name: sys-sys-log
  ::
  ::  Base data comes from +database.event-log in server-state-1.
  ::
  ::  The view body is a %crud-txn query over db.sys.sys-log.  It exposes the
  ::  complete persisted event: tmsp, agent, action, component, database,
  ::  namespace, name, target-database, target-namespace, target-relation, 
  ::  message.
  ::  agent is the schema provenance path rendered as text.
  ::
  ::  Orders by tmsp descending, then component, name, and action ascending.
  |=  [database=@tas provenance=path tmsp=@da]
  ^-  view
  =/  columns=(list column:ast)
        %-  addr-columns  :~  [%column %tmsp ~.da 0]
                              [%column %agent ~.ta 0]
                              [%column %action ~.tas 0]
                              [%column %component ~.tas 0]
                              [%column %database ~.tas 0]
                              [%column %namespace ~.tas 0]
                              [%column %relation ~.tas 0]
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
                  %tmsp  ::column=@tas
                  ~  ::alias=(unit @t)
                  %.n  ::ascending=?
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
                  %relation  ::column=@tas
                  ~  ::alias=(unit @t)
                  %.y  ::ascending=?
              :+  %ordering-column
                  :^  %qualified-column    ::qualified-column
                  :*  %qualified-table  ::qualifier
                      ~           ::ship=(unit @p)
                      database    ::database=@tas
                      %sys        ::namespace=@tas
                      %sys-log  ::name=@tas
                      ~                    ::alias=(unit @t)
                      ==
                  %action      ::column=@tas
                  ~  ::alias=(unit @t)
                  %.y  ::ascending=?
              ==
          ==
::
++  sys-data-log-view
  ::  view name: sys-data-log
  ::
  ::  Base data comes from the full +database.content data history in
  ::  server-state-1.  +populate-system-view walks every +data snapshot, and
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
++  apply-ordering
  |=  v=view
  ^-  view
  ?.  ?=([%query *] body.crud-txn.v)  v
  =/  q=query:ast  +.body.crud-txn.v
  ?~  order-by.q  v
  v(ordering (make-ordering columns.v order-by.q))
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
          (sort dbes ~(order order-row ordering.view))
          columns.view
  ::
  %namespaces
    =/  namespaces  (~(urn by namespaces.schema) |=([k=@tas v=@da] ~[k v]))
    =/  nses  %+  skim
                  `(list (list @))`~(val by namespaces)
                  |=(a=(list @) (lte +<.a cache-time))
    %+  atoms-2-mapped-row
          (sort nses ~(order order-row ordering.view))
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
        (sort tbls ~(order order-row ordering.view))
        columns.view
  ::
  %table-keys
    =/  udata=data  (get-data content.database cache-time)
    =/  table-keys  ^-  (list (list @))
                          %-  zing
                                  %+  turn  ~(tap by files.udata)
                                      ~(foo sys-view-table-keys tables.schema)
    %+  atoms-2-mapped-row
        (sort table-keys ~(order order-row ordering.view))
        columns.view
  ::
  %columns
    =/  udata=data  (get-data content.database cache-time)
    =/  columns  ^-  (list (list @))
                      %-  zing
                            %+  turn  ~(tap by files.udata)
                                ~(foo sys-view-columns tables.schema)
    %+  atoms-2-mapped-row
        (sort columns ~(order order-row ordering.view))
        columns.view
  ::
  %sys-log
    =/  log   %+  skim
                  (turn event-log.database sys-view-sys-log-event)
                  |=(a=(list @) (lte -.a cache-time))
    %+  atoms-2-mapped-row
        (sort `(list (list @))`log ~(order order-row ordering.view))
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
        (sort tbls ~(order order-row ordering.view))
        columns.view
  ==
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
  |_  tables=(map [@tas @tas] table)
  ++  foo
    |=  [k=[@tas @tas] =file]
    ^-  (list (list @))
    =/  tbl  (~(got by tables) [-.k +.k])
    ~[~[-.k +.k (crip (spud provenance.tbl)) tmsp.tbl rowcount.file]]
  --
::
++  sys-view-table-keys
  |_  tables=(map [@tas @tas] table)
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
          |=([n=key-column a=@] [~[a name.n ascending.n] +(a)])
    (turn p.keys |=(a=(list @) (weld aa a)))
  --
::
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
++  order-row
  ::  Currently orders rows inversely so +select-columns is not required to flop
  ::  its output
  |_  index=(list column-order)
  :: to do: accommodate varying row types
  ++  order
  |=  [p=(list @) q=(list @)]
  =/  k=(list [aor=? ascending=? offset=@ud])  index
  |-  ^-  ?
  ?~  k  %.n
  =/  pp=(list @)
    ?:  =(0 ->+.k)  p                      ::offset of current index
    (oust [0 ->+.k] p)
  =/  qq=(list @)
    ?:  =(0 ->+.k)  q                      ::offset of current index
    (oust [0 ->+.k] q)
  ?:  =(-.pp -.qq)  $(k +.k)
  ?:  =(-<.k %.y)  (alpha -.qq -.pp)
  ?:  ->-.k  (gth -.pp -.qq)
  (lth -.pp -.qq)
  --
::
++  make-ordering
  |=  [columns=(list column:ast) order=*]
  ^-  (list column-order)
  =/  out  *(list column-order)
  |-
  ?~  order  (flop out)
  ~|  "bad order column:  {<-.order>} ..."
  ?>  ?=(ordering-column:ast -.order)
  =/  ordering=ordering-column:ast  `ordering-column:ast`-.order
  =/  order-column  column.ordering
  =/  col-i=(unit [@ @ta])
        ?:  ?=(qualified-column:ast order-column)
          (try-find-col-index columns name.order-column)
        ~|("order column error:  {<order-column>}" !!)
  ?~  col-i  $(order +.order)
  =/  offset-type  (need col-i)
  %=  $
    order  +.order
    out
      ?:  ?|(=(~.t +.offset-type) =(~.ta +.offset-type) =(~.tas +.offset-type))
        [[%.y ascending.ordering -.offset-type] out]
      [[%.n ascending.ordering -.offset-type] out]
  ==
::
++  try-find-col-index
  |=  [a=(list column:ast) name=@tas]
  =/  i  0
  |-  ^-  (unit [@ @ta])
  ?~  a  ~
  ?:  =(name name.i.a)  `[i type.i.a]
  $(a t.a, i +(i))
::
++  atoms-2-mapped-row
  |=  [p=(list (list @)) q=(list column:ast)]
  ^-  [@ (list (map @tas @))]
  =/  rows  *(list (map @tas @))
  =/  i  0
  |-
  ?~  p  [i (flop rows)]
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
