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
    =/  columns=(list column:ast)  :~  [%column %database ~.tas]
                                       [%column %sys-agent ~.ta]
                                       [%column %sys-tmsp ~.da]
                                       [%column %data-ship ~.p]
                                       [%column %data-agent ~.ta]
                                       [%column %data-tmsp ~.da]
                                       ==
    :*  %view
        provenance                                            ::provenance=path
        tmsp                                                    ::tmsp=@da
        :+  %selection                                          ::selection
            ~                                                 ::ctes=(list cte)
            sys-sys-dbs-query                                   ::query
        (malt (spun columns make-col-lu-data))                  ::column-lookup
        (malt (turn columns |=(a=column:ast [name.a type.a])))  ::column-types
        columns                                         ::columns=(list column)
        ~                                         ::ordering=(list column-order)
        ==
++  sys-sys-dbs-query
    ^-  (tree set-function:ast)
    :+  :*  %query
            :-  ~           ::from=(unit from)
                :^  %from
                    :-  %table-set  ::object=table-set
                        :*  %qualified-object  ::object=query-source
                            ~
                            %sys
                            %sys
                            %databases
                            ~
                            ==
                    ~  ::(unit as-of)
                    ~  ::joins=(list joined-object)
            ~  ::scalars=(list scalar-function)
            ~  ::predicate=(unit predicate)
            ~  ::group-by=(list grouping-column)
            ~  ::having=(unit predicate)
            :^  %select  ::selection=select
                ~               ::top=(unit @ud)
                ~               ::bottom=(unit @ud)
                :~  :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
                            ~                    ::ship=(unit @p)
                            %sys                 ::database=@tas
                            %sys                 ::namespace=@tas
                            %databases           ::name=@tas
                            ~
                            ==
                        %database              ::column=@tas
                        `%database             ::alias=(unit @t)
                    :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
                            ~                    ::ship=(unit @p)
                            %sys                 ::database=@tas
                            %sys                 ::namespace=@tas
                            %databases           ::name=@tas
                            ~
                            ==
                        %sys-agent             ::column=@tas
                        `%sys-agent            ::alias=(unit @t)
                    :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
                            ~                  ::ship=(unit @p)
                            %sys               ::database=@tas
                            %sys               ::namespace=@tas
                            %databases         ::name=@tas
                            ~
                            ==
                        %sys-tmsp            ::column=@tas
                        `%sys-tmsp           ::alias=(unit @t)
                    :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
                            ~                  ::ship=(unit @p)
                            %sys               ::database=@tas
                            %sys               ::namespace=@tas
                            %databases         ::name=@tas
                            ~
                            ==
                        %data-ship           ::column=@tas
                        `%data-ship          ::alias=(unit @t)
                    :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
                            ~                  ::ship=(unit @p)
                            %sys               ::database=@tas
                            %sys               ::namespace=@tas
                            %databases         ::name=@tas
                            ~
                            ==
                        %data-agent          ::column=@tas
                        `%data-agent         ::alias=(unit @t)
                    :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
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
                    :*  %qualified-object  ::qualifier
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
                    :*  %qualified-object  ::qualifier
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
                    :*  %qualified-object  ::qualifier
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
    =/  columns=(list column:ast)  :~  [%column %namespace ~.tas]
                                       [%column %tmsp ~.da]
                                       ==
    :*  %view
        provenance                     ::provenance=path
        tmsp                           ::tmsp=@da
        :+  %selection                 ::selection
            ~                              ::ctes=(list cte)
            (sys-namespaces-query db)      ::query
        (malt (spun columns make-col-lu-data))  ::column-lookup
        (malt (turn columns |=(a=column:ast [name.a type.a])))  ::column-types
        columns                        ::columns=(list column)
        ~                              ::ordering=(list column-order)
        ==
++  sys-namespaces-query
    |=  database=@tas
    ^-  (tree set-function:ast)
    :+  :*  %query
            :-  ~           ::from=(unit from)
                :^  %from
                    :-  %table-set  ::object=table-set
                        :*  %qualified-object  ::object=query-source
                            ~
                            database
                            %sys
                            %namespaces
                            ~
                            ==
                    ~  ::(unit as-of)
                    ~               ::joins=(list joined-object)
            ~  ::scalars=(list scalar-function)
            ~  ::predicate=(unit predicate)
            ~  ::group-by=(list grouping-column)
            ~  ::having=(unit predicate)
            :^  %select  ::selection=select
                ~               ::top=(unit @ud)
                ~               ::bottom=(unit @ud)
                :~  :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
                            ~                    ::ship=(unit @p)
                            database             ::database=@tas
                            %sys                 ::namespace=@tas
                            %namespaces          ::name=@tas
                            ~
                            ==
                        %namespace             ::column=@tas
                        `%namespace            ::alias=(unit @t)
                    :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
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
                    :*  %qualified-object  ::qualifier
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
                    :*  %qualified-object  ::qualifier
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
    =/  columns=(list column:ast)  :~  [%column %namespace ~.tas]
                                       [%column %name ~.tas]
                                       [%column %agent ~.ta]
                                       [%column %tmsp ~.da]
                                       [%column %row-count ~.ud]
                                       ==
    :*  %view
        provenance                     ::provenance=path
        tmsp                           ::tmsp=@da
        :+  %selection                 ::selection
            ~                              ::ctes=(list cte)
            (sys-tables-query db)          ::query
        (malt (spun columns make-col-lu-data))  ::column-lookup
        (malt (turn columns |=(a=column:ast [name.a type.a])))  ::column-types
        columns                        ::columns=(list column)
        ~                              ::ordering=(list column-order)
        ==
++  sys-tables-query
    |=  database=@tas
    ^-  (tree set-function:ast)
    :+  :*  %query
            :-  ~            ::from=(unit from)
                :^  %from
                    :-  %table-set  ::object=table-set
                        :*  %qualified-object  ::object=query-source
                            ~
                            database
                            %sys
                            %tables
                            ~
                            ==
                    ~  ::(unit as-of)
                    ~  ::joins=(list joined-object)
            ~  ::scalars=(list scalar-function)
            ~  ::predicate=(unit predicate)
            ~  ::group-by=(list grouping-column)
            ~  ::having=(unit predicate)
            :^  %select  ::selection=select
                ~               ::top=(unit @ud)
                ~               ::bottom=(unit @ud)
                :~  :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
                            ~                    ::ship=(unit @p)
                            database             ::database=@tas
                            %sys                 ::namespace=@tas
                            %tables              ::name=@tas
                            ~                    ::alias=(unit @t)
                            ==
                        %namespace             ::column=@tas
                        `%namespace            ::alias=(unit @t)
                    :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
                            ~                    ::ship=(unit @p)
                            database             ::database=@tas
                            %sys                 ::namespace=@tas
                            %tables              ::name=@tas
                            ~                    ::alias=(unit @t)
                            ==
                        %name                  ::column=@tas
                        `%name                 ::alias=(unit @t)
                    :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
                            ~                    ::ship=(unit @p)
                            database             ::database=@tas
                            %sys                 ::namespace=@tas
                            %tables              ::name=@tas
                            ~                    ::alias=(unit @t)
                            ==
                        %agent                 ::column=@tas
                        `%agent                ::alias=(unit @t)
                    :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
                            ~                    ::ship=(unit @p)
                            database             ::database=@tas
                            %sys                 ::namespace=@tas
                            %tables              ::name=@tas
                            ~                    ::alias=(unit @t)
                            ==
                        %tmsp                  ::column=@tas
                        `%tmsp                 ::alias=(unit @t)
                    :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
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
                    :*  %qualified-object  ::qualifier
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
                    :*  %qualified-object  ::qualifier
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
    =/  columns=(list column:ast)  :~  [%column %namespace ~.tas]
                                       [%column %name ~.tas]
                                       [%column %key-ordinal ~.ud]
                                       [%column %key ~.tas]
                                       [%column %key-ascending ~.f]
                                       ==
    :*  %view
        provenance                     ::provenance=path
        tmsp                           ::tmsp=@da
        :+  %selection                 ::selection
            ~                              ::ctes=(list cte)
            (sys-tables-query db)          ::query
        (malt (spun columns make-col-lu-data))  ::column-lookup
        (malt (turn columns |=(a=column:ast [name.a type.a])))  ::column-types
        columns                        ::columns=(list column)
        ~                              ::ordering=(list column-order)
        ==
++  sys-table-keys-query
    |=  database=@tas
    ^-  (tree set-function:ast)
    :+  :*  %query
            :-  ~            ::from=(unit from)
                :^  %from
                    :-  %table-set  ::object=table-set
                        :*  %qualified-object  ::object=query-source
                            ~
                            database
                            %sys
                            %table-keys
                            ~                    ::alias=(unit @t)
                            ==
                    ~  ::(unit as-of)
                    ~  ::joins=(list joined-object)
            ~  ::scalars=(list scalar-function)
            ~  ::predicate=(unit predicate)
            ~  ::group-by=(list grouping-column)
            ~  ::having=(unit predicate)
            :^  %select  ::selection=select
                ~               ::top=(unit @ud)
                ~               ::bottom=(unit @ud)
                :~  :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
                            ~                    ::ship=(unit @p)
                            database             ::database=@tas
                            %sys                 ::namespace=@tas
                            %tables              ::name=@tas
                            ~                    ::alias=(unit @t)
                            ==
                        %namespace             ::column=@tas
                        `%namespace            ::alias=(unit @t)
                    :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
                            ~                    ::ship=(unit @p)
                            database             ::database=@tas
                            %sys                 ::namespace=@tas
                            %tables              ::name=@tas
                            ~                    ::alias=(unit @t)
                            ==
                        %name                  ::column=@tas
                        `%name                 ::alias=(unit @t)
                    :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
                            ~                    ::ship=(unit @p)
                            database             ::database=@tas
                            %sys                 ::namespace=@tas
                            %tables              ::name=@tas
                            ~                    ::alias=(unit @t)
                            ==
                        %key-ordinal           ::column=@tas
                        `%key-ordinal          ::alias=(unit @t)
                    :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
                            ~                    ::ship=(unit @p)
                            database             ::database=@tas
                            %sys                 ::namespace=@tas
                            %tables              ::name=@tas
                            ~                    ::alias=(unit @t)
                            ==
                        %key                   ::column=@tas
                        `%key                  ::alias=(unit @t)
                    :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
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
                    :*  %qualified-object  ::qualifier
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
                    :*  %qualified-object  ::qualifier
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
                    :*  %qualified-object  ::qualifier
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
    =/  columns=(list column:ast)  :~  [%column %namespace ~.tas]
                                       [%column %name ~.tas]
                                       [%column %col-ordinal ~.ud]
                                       [%column %col-name ~.tas]
                                       [%column %col-type ~.ta]
                                       ==
    :*  %view
        provenance                     ::provenance=path
        tmsp                           ::tmsp=@da
        :+  %selection                 ::selection
            ~                              ::ctes=(list cte)
            (sys-columns-query db)         ::query
        (malt (spun columns make-col-lu-data))  ::column-lookup
        (malt (turn columns |=(a=column:ast [name.a type.a])))  ::column-types
        columns                        ::columns=(list column)
        ~                              ::ordering=(list column-order)
        ==
++  sys-columns-query
    |=  database=@tas
    ^-  (tree set-function:ast)
    :+  :*  %query
            :-  ~          ::from=(unit from)
                :^  %from
                    :-  %table-set  ::object=table-set
                        :*  %qualified-object  ::object=query-source
                            ~
                            database
                            %sys
                            %columns
                            ~                    ::alias=(unit @t)
                            ==
                    ~  ::(unit as-of)
                    ~  ::joins=(list joined-object)
            ~  ::scalars=(list scalar-function)
            ~  ::predicate=(unit predicate)
            ~  ::group-by=(list grouping-column)
            ~  ::having=(unit predicate)
            :^  %select  ::selection=select
                ~               ::top=(unit @ud)
                ~               ::bottom=(unit @ud)
                :~  :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
                            ~                    ::ship=(unit @p)
                            database             ::database=@tas
                            %sys                 ::namespace=@tas
                            %columns             ::name=@tas
                            ~                    ::alias=(unit @t)
                            ==
                        %namespace             ::column=@tas
                        `%namespace            ::alias=(unit @t)
                    :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
                            ~                    ::ship=(unit @p)
                            database             ::database=@tas
                            %sys                 ::namespace=@tas
                            %columns             ::name=@tas
                            ~                    ::alias=(unit @t)
                            ==
                        %name                  ::column=@tas
                        `%name                 ::alias=(unit @t)
                    :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
                            ~                    ::ship=(unit @p)
                            database             ::database=@tas
                            %sys                 ::namespace=@tas
                            %columns             ::name=@tas
                            ~                    ::alias=(unit @t)
                            ==
                        %col-ordinal           ::column=@tas
                        `%col-ordinal          ::alias=(unit @t)
                    :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
                            ~                    ::ship=(unit @p)
                            database             ::database=@tas
                            %sys                 ::namespace=@tas
                            %columns             ::name=@tas
                            ~                    ::alias=(unit @t)
                            ==
                        %col-name              ::column=@tas
                        `%col-name             ::alias=(unit @t)
                    :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
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
                    :*  %qualified-object  ::qualifier
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
                    :*  %qualified-object  ::qualifier
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
                    :*  %qualified-object  ::qualifier
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
    =/  columns=(list column:ast)  :~  [%column %tmsp ~.da]
                                       [%column %agent ~.ta]
                                       [%column %component ~.tas]
                                       [%column %name ~.tas]
                                       ==
    :*  %view
        provenance                     ::provenance=path
        tmsp                           ::tmsp=@da
        :+  %selection                 ::selection
            ~                              ::ctes=(list cte)
            (sys-sys-log-query database)   ::query
        (malt (spun columns make-col-lu-data))  ::column-lookup
        (malt (turn columns |=(a=column:ast [name.a type.a])))  ::column-types
        columns                        ::columns=(list column)
        ~                              ::ordering=(list column-order)
        ==
++  sys-sys-log-query
    |=  database=@tas
    ^-  (tree set-function:ast)
    :+  :*  %query
            :-  ~            ::from=(unit from)
                :^  %from
                    :-  %table-set  ::object=table-set
                        :*  %qualified-object  ::object=query-source
                            ~
                            database
                            %sys
                            %sys-log
                            ~                    ::alias=(unit @t)
                            ==
                    ~  ::(unit as-of)
                    ~  ::joins=(list joined-object)
            ~  ::scalars=(list scalar-function)
            ~  ::predicate=(unit predicate)
            ~  ::group-by=(list grouping-column)
            ~  ::having=(unit predicate)
            :^  %select  ::selection=select
                ~               ::top=(unit @ud)
                ~               ::bottom=(unit @ud)
                :~  :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
                            ~                    ::ship=(unit @p)
                            database             ::database=@tas
                            %sys                 ::namespace=@tas
                            %sys-log             ::name=@tas
                            ~                    ::alias=(unit @t)
                            ==
                        %tmsp                  ::column=@tas
                        `%tmsp                 ::alias=(unit @t)
                    :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
                            ~                    ::ship=(unit @p)
                            database             ::database=@tas
                            %sys                 ::namespace=@tas
                            %sys-log             ::name=@tas
                            ~                    ::alias=(unit @t)
                            ==
                        %agent                 ::column=@tas
                        `%agent                ::alias=(unit @t)
                    :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
                            ~                    ::ship=(unit @p)
                            database             ::database=@tas
                            %sys                 ::namespace=@tas
                            %sys-log             ::name=@tas
                            ~                    ::alias=(unit @t)
                            ==
                        %component             ::column=@tas
                        `%component            ::alias=(unit @t)
                    :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
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
                    :*  %qualified-object  ::qualifier
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
                    :*  %qualified-object  ::qualifier
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
                    :*  %qualified-object  ::qualifier
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
    =/  columns=(list column:ast)  :~  [%column %tmsp ~.da]
                                       [%column %ship ~.p]
                                       [%column %agent ~.ta]
                                       [%column %namespace ~.tas]
                                       [%column %table ~.tas]
                                       [%column %row-count ~.ud]
                                       ==
    :*  %view
        provenance                     ::provenance=path
        tmsp                           ::tmsp=@da
        :+  %selection                 ::selection
            ~                              ::ctes=(list cte)
            (sys-data-log-query database)  ::query
        (malt (spun columns make-col-lu-data))  ::column-lookup
        (malt (turn columns |=(a=column:ast [name.a type.a])))  ::column-types
        columns                        ::columns=(list column)
        ~                              ::ordering=(list column-order)
        ==
++  sys-data-log-query
    |=  database=@tas
    ^-  (tree set-function:ast)
    :+  :*  %query
            :-  ~           ::from=(unit from)
                :^  %from
                    :-  %table-set  ::object=table-set
                        :*  %qualified-object  ::object=query-source
                            ~
                            database
                            %sys
                            %data-log
                            ~                    ::alias=(unit @t)
                            ==
                    ~       ::(unit as-of)
                    ~       ::joins=(list joined-object)
            ~            ::scalars=(list scalar-function)
            ~            ::predicate=(unit predicate)
            ~            ::group-by=(list grouping-column)
            ~            ::having=(unit predicate)
            :^  %select  ::selection=select
                ~               ::top=(unit @ud)
                ~               ::bottom=(unit @ud)
                :~  :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
                            ~                    ::ship=(unit @p)
                            database             ::database=@tas
                            %sys                 ::namespace=@tas
                            %data-log            ::name=@tas
                            ~                    ::alias=(unit @t)
                            ==
                        %tmsp                  ::column=@tas
                        `%tmsp                 ::alias=(unit @t)
                    :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
                            ~                    ::ship=(unit @p)
                            database             ::database=@tas
                            %sys                 ::namespace=@tas
                            %data-log            ::name=@tas
                            ~                    ::alias=(unit @t)
                            ==
                        %ship                ::column=@tas
                        `%ship               ::alias=(unit @t)
                    :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
                            ~                  ::ship=(unit @p)
                            database           ::database=@tas
                            %sys               ::namespace=@tas
                            %data-log           ::name=@tas
                            ~                    ::alias=(unit @t)
                            ==
                        %agent               ::column=@tas
                        `%agent              ::alias=(unit @t)
                    :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
                            ~                    ::ship=(unit @p)
                            database             ::database=@tas
                            %sys                 ::namespace=@tas
                            %data-log            ::name=@tas
                            ~                    ::alias=(unit @t)
                            ==
                        %namespace             ::column=@tas
                        `%namespace            ::alias=(unit @t)
                    :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
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
                    :*  %qualified-object  ::qualifier
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
                    :*  %qualified-object  ::qualifier
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
                    :*  %qualified-object  ::qualifier
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
    ?~  set-functions.selection.v  ~|("can't get here" !!)
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
--
