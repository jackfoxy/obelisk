/-  ast, *obelisk, *server-state
/+  *utils
|%
::
::  +sys-sys-dbs-view:  [path @da] -> view
::
::  view name: sys-databases
::
::      databases
::         /\
::      sys  content
::
::  *  only available in %sys database
::  *  initial cache key created upon new database creation
::  *  subsequent cache keys created upon creation of new user database schema
::     and data keys
++  sys-sys-dbs-view
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
        tmsp                                                    ::tmsp=@da
        :+  %selection                                          ::selection
            ~                                                 ::ctes=(list cte)
            sys-sys-dbs-query                                   ::query
        (malt (spun columns mk-col-lu-data))                  ::column-lookup
        %-  malt
          %+  turn  columns
                    |=(a=column:ast [name.a [type.a addr.a]])  ::typ-addr-lookup
        columns                                         ::columns=(list column)
        ~                                         ::ordering=(list column-order)
        ==
++  sys-sys-dbs-query
    ^-  (tree set-function:ast)
    :+  :*  %query
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
        ~
        ~
::
::  +sys-namespaces-view:  [@tas path @da] -> view
::
::  view name: sys-namespaces
::
::      schema
::         \
::        namespaces
::
::  *  initial cache key created upon database creation
::  *  subsequent cache keys created upon create and drop namespace
++  sys-namespaces-view
    |=  [db=@tas provenance=path tmsp=@da]
    ^-  view
    =/  columns=(list column:ast)
          %-  addr-columns  :~  [%column %namespace ~.tas 0]
                                [%column %tmsp ~.da 0]
                                ==
    :*  %view
        provenance                     ::provenance=path
        tmsp                           ::tmsp=@da
        :+  %selection                 ::selection
            ~                              ::ctes=(list cte)
            (sys-namespaces-query db)      ::query
        (malt (spun columns mk-col-lu-data))  ::column-lookup
        %-  malt
          %+  turn  columns
                    |=(a=column:ast [name.a [type.a addr.a]])  ::typ-addr-lookup
        columns                        ::columns=(list column)
        ~                              ::ordering=(list column-order)
        ==
++  sys-namespaces-query
    |=  database=@tas
    ^-  (tree set-function:ast)
    :+  :*  %query
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
        ~
        ~
::
::  + sys-tables-view:  [@tas path @da] -> view
::
::    tables  files
::
::  view name: sys-tables
::
::  *  initial cache key created upon table creation
::  *  subsequent cache keys created upon...drop table, insert
++  sys-tables-view
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
        provenance                     ::provenance=path
        tmsp                           ::tmsp=@da
        :+  %selection                 ::selection
            ~                              ::ctes=(list cte)
            (sys-tables-query db)          ::query
        (malt (spun columns mk-col-lu-data))  ::column-lookup
        %-  malt
          %+  turn  columns
                    |=(a=column:ast [name.a [type.a addr.a]])  ::typ-addr-lookup
        columns                        ::columns=(list column)
        ~                              ::ordering=(list column-order)
        ==
++  sys-tables-query
    |=  database=@tas
    ^-  (tree set-function:ast)
    :+  :*  %query
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
        ~
        ~
::
::  +sys-table-keys-view:  [@tas path @da] -> view
::
::  *  initial cache key created upon table creation
::  *  subsequent cache keys created upon...drop table
++  sys-table-keys-view
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
        provenance                     ::provenance=path
        tmsp                           ::tmsp=@da
        :+  %selection                 ::selection
            ~                              ::ctes=(list cte)
            (sys-tables-query db)          ::query
        (malt (spun columns mk-col-lu-data))  ::column-lookup
        %-  malt
          %+  turn  columns
                    |=(a=column:ast [name.a [type.a addr.a]])  ::typ-addr-lookup
        columns                        ::columns=(list column)
        ~                              ::ordering=(list column-order)
        ==
++  sys-table-keys-query
    |=  database=@tas
    ^-  (tree set-function:ast)
    :+  :*  %query
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
                :+  %ordering-column
                    :^  %qualified-column    ::qualified-column
                    :*  %qualified-table  ::qualifier
                        ~           ::ship=(unit @p)
                        database    ::database=@tas
                        %sys        ::namespace=@tas
                        %tables  ::name=@tas
                        ~                    ::alias=(unit @t)
                        ==
                    %key-ordinal  ::column=@tas
                    ~  ::alias=(unit @t)
                    %.y  ::ascending=?
                ==
            ==
        ~
        ~
::
::  +sys-columns-view:  [@tas path @da] -> view
++  sys-columns-view
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
        provenance                     ::provenance=path
        tmsp                           ::tmsp=@da
        :+  %selection                 ::selection
            ~                              ::ctes=(list cte)
            (sys-columns-query db)         ::query
        (malt (spun columns mk-col-lu-data))  ::column-lookup
        %-  malt
          %+  turn  columns
                    |=(a=column:ast [name.a [type.a addr.a]])  ::typ-addr-lookup
        columns                        ::columns=(list column)
        ~                              ::ordering=(list column-order)
        ==
++  sys-columns-query
    |=  database=@tas
    ^-  (tree set-function:ast)
    :+  :*  %query
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
        ~
        ~
::
::  +sys-sys-log-view:  [@tas path @da] -> view
++  sys-sys-log-view
    |=  [database=@tas provenance=path tmsp=@da]
    ^-  view
    =/  columns=(list column:ast)
          %-  addr-columns  :~  [%column %tmsp ~.da 0]
                                [%column %agent ~.ta 0]
                                [%column %component ~.tas 0]
                                [%column %name ~.tas 0]
                                ==
    :*  %view
        provenance                     ::provenance=path
        tmsp                           ::tmsp=@da
        :+  %selection                 ::selection
            ~                              ::ctes=(list cte)
            (sys-sys-log-query database)   ::query
        (malt (spun columns mk-col-lu-data))  ::column-lookup
        %-  malt
          %+  turn  columns
                    |=(a=column:ast [name.a [type.a addr.a]])  ::typ-addr-lookup
        columns                        ::columns=(list column)
        ~                              ::ordering=(list column-order)
        ==
++  sys-sys-log-query
    |=  database=@tas
    ^-  (tree set-function:ast)
    :+  :*  %query
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
                        %name                  ::column=@tas
                        `%name                 ::alias=(unit @t)
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
                        %sys-log  ::name=@tas
                        ~                    ::alias=(unit @t)
                        ==
                    %name  ::column=@tas
                    ~  ::alias=(unit @t)
                    %.y  ::ascending=?
                ==
            ==
        ~
        ~
::
::  +sys-data-log-view:  [@tas path @da] -> view
++  sys-data-log-view
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
        provenance                     ::provenance=path
        tmsp                           ::tmsp=@da
        :+  %selection                 ::selection
            ~                              ::ctes=(list cte)
            (sys-data-log-query database)  ::query
        (malt (spun columns mk-col-lu-data))  ::column-lookup
        %-  malt
          %+  turn  columns
                    |=(a=column:ast [name.a [type.a addr.a]])  ::typ-addr-lookup
        columns                        ::columns=(list column)
        ~                              ::ordering=(list column-order)
        ==
++  sys-data-log-query
    |=  database=@tas
    ^-  (tree set-function:ast)
    :+  :*  %query
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
        ~
        ~
::
++  apply-ordering
    |=  v=view
    ^-  view
    ?~  set-functions.selection.v  ~|("apply-ordering can't get here" !!)
    =/  qsf=set-function:ast  `set-function:ast`n.set-functions.selection.v
    ?~  +>+>+>+.qsf  v  
    v(ordering (make-ordering columns.v +>+>+>+.qsf))
::
::  +populate-system-view:
::    [state=server =database =schema =view name=@tas]
::    -> (list (list @))
::
::  Side effect: populate view-cache
::               theoretically a state change, but referentially transparent
++  populate-system-view
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
        ::      :: to do: rewrite as jagged when architecture available
      =/  sys=(list ^schema)
            (turn (tap:schema-key sys.database) |=(b=[@da ^schema] +.b))
      =/  namespaces  (zing (turn sys sys-view-sys-log-ns))
      =/  tbls        (zing (turn sys sys-view-sys-log-tbl))
      =/  log   %+  skim
                    (weld `(list (list @))`namespaces `(list (list @))`tbls)
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
++  sys-view-sys-log-ns
  |=  a=schema
    ^-  (list (list @))
    =/  namespaces  %+  skim
                    ~(val by (~(urn by namespaces.a) |=([k=@tas v=@da] [k v])))
                    |=(b=[ns=@tas tmsp=@da] =(tmsp.a tmsp.b))
    %+  turn  namespaces
      |=([ns=@tas tmsp=@da] ~[tmsp.a (crip (spud provenance.a)) %namespace ns])
::
++  sys-view-data-log
  |=  a=data
  ^-  (list (list @))
  =/  tbls  %+  skim
                %~  val  by
                    (~(urn by files.a) |=([k=[@tas @tas] =file] [k file]))
                |=(b=[k=[@tas @tas] =file] =(tmsp.a tmsp.file.b))
  %+  turn  tbls
   |=([k=[@tas @tas] =file] ~[tmsp.a ship.a (crip (spud provenance.a)) -.k +.k rowcount.file])
::
++  sys-view-sys-log-tbl
  |=  a=schema
  ^-  (list (list @))
  =/  tbls  %+  skim
                %~  val  by
                    (~(urn by tables.a) |=([k=[@tas @tas] =table] [k table]))
                |=(b=[k=[@tas @tas] =table] =(tmsp.a tmsp.table.b))
  %+  turn  tbls
    |=([k=[@tas @tas] =table] ~[tmsp.a (crip (spud provenance.a)) -.k +.k])
++  get-data
  |=  [sys=((mop @da data) gth) time=@da]
  ^-  data
  =/  exact  (get:data-key sys time)
  ?^  exact  (need exact)
  =/  prior  (pry:data-key (lot:data-key sys `time ~))
  ?~  prior  ~|("data not available for {<time>}" !!)
  +:(need prior)
::
::  +order:  [(list @) (list @)] -> ?
::
::  Currently orders rows inversely so +select-columns is not required to flop
::  its output
++  order-row
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
::  +make-ordering:  [(list column:ast) *] -> (list column-order)
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
::  +atoms-2-mapped-row:  [(list (list @)) (list column:ast)]
::                        -> (list (map @tas @))
++  atoms-2-mapped-row
  |=  [p=(list (list @)) q=(list column:ast)]
  ^-  [@ (list (map @tas @))]
  =/  rows  *(list (map @tas @))
  =/  i  0
  |-
  ?~  p  [i (flop rows)]
  $(i +(i), p +.p, rows [(malt (zip-columns -.p q)) rows])
::
::  +zip-columns: [(list @) (list column:ast)] -> (list [@tas @])
++  zip-columns
  |*  [a=(list @) b=(list column:ast)]
  ^-  (list [@tas @])
  =/  c  *(list [@tas @])
  |-
  ?~  a  ?~  b  c  ~|('column lists of unequal length' !!)
  ?~  b  ~|('column lists of unequal length' !!)
  $(a +.a, b +.b, c [[name.i.b -.a] c])
--
