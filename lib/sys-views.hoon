/-  ast, *obelisk
/+  *utils
|%
++  sys-sys-dbs-view
    |=  [provenance=path tmsp=@da]
    ^-  view
    :*  %view
        provenance                     ::provenance=path
        tmsp                           ::tmsp=@da
        :+  %transform                 ::transform
            ~                              ::ctes=(list cte)
            sys-sys-dbs-query              ::query
        :~  [%column %database ~.tas]  ::columns=(list column)
            [%column %sys-agent ~.tas] 
            [%column %sys-tmsp ~.da] 
            [%column %data-ship ~.p] 
            [%column %data-agent ~.tas] 
            [%column %data-tmsp ~.da]
            ==
        ~                              ::ordering=(list column-order)
        ==
++  sys-sys-dbs-query
    ^-  (tree set-function:ast)
    :+  :*  %query
            :-  ~           ::from=(unit from)
                :+  %from
                    :+  %table-set  ::object=table-set
                        :*  %qualified-object  ::object=query-source
                            ~
                            %sys
                            %sys
                            %databases
                            ==
                        ~  ::alias=(unit @t)
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
                            ==
                        %database              ::column=@tas
                        ~                      ::alias=(unit @t)
                    :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
                            ~                    ::ship=(unit @p)
                            %sys                 ::database=@tas
                            %sys                 ::namespace=@tas
                            %databases           ::name=@tas
                            ==
                        %sys-agent             ::column=@tas
                        ~                      ::alias=(unit @t)
                    :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
                            ~                  ::ship=(unit @p)
                            %sys               ::database=@tas
                            %sys               ::namespace=@tas
                            %databases         ::name=@tas
                            ==
                        %sys-tmsp            ::column=@tas
                        ~                    ::alias=(unit @t)
                    :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
                            ~                  ::ship=(unit @p)
                            %sys               ::database=@tas
                            %sys               ::namespace=@tas
                            %databases         ::name=@tas
                            ==
                        %data-ship           ::column=@tas
                        ~                    ::alias=(unit @t)
                    :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
                            ~                  ::ship=(unit @p)
                            %sys               ::database=@tas
                            %sys               ::namespace=@tas
                            %databases         ::name=@tas
                            ==
                        %data-agent          ::column=@tas
                        ~                    ::alias=(unit @t)
                    :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
                            ~                  ::ship=(unit @p)
                            %sys               ::database=@tas
                            %sys               ::namespace=@tas
                            %databases         ::name=@tas
                            ==
                        %data-tmsp          ::column=@tas
                        ~                    ::alias=(unit @t)
                    ==
            :~      ::order-by=(list ordering-column)
                :+  %ordering-column
                    :^  %qualified-column    ::qualified-column
                    :*  %qualified-object  ::qualifier
                        ~           ::ship=(unit @p)
                        %sys        ::database=@tas
                        %sys        ::namespace=@tas
                        %databases  ::name=@tas
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
                        ==
                    %data-tmsp  ::column=@tas
                    ~  ::alias=(unit @t)
                    %.y  ::ascending=?
                ==
            ==
        ~
        ~
::
++  sys-namespaces-view
    |=  [db=@tas provenance=path tmsp=@da]
    ^-  view
    :*  %view
        provenance                     ::provenance=path
        tmsp                           ::tmsp=@da
        :+  %transform                 ::transform
            ~                              ::ctes=(list cte)
            (sys-namespaces-query db)      ::query
        :~  [%column %namespace ~.tas] ::columns=(list column)
            [%column %tmsp ~.da]
            ==
        ~                              ::ordering=(list column-order)
        ==
++  sys-namespaces-query
    |=  database=@tas
    ^-  (tree set-function:ast)
    :+  :*  %query
            :-  ~           ::from=(unit from)
                :+  %from
                    :+  %table-set  ::object=table-set
                        :*  %qualified-object  ::object=query-source
                            ~
                            database
                            %sys
                            %namespaces
                            ==
                        ~                      ::alias=(unit @t)
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
                            ~                  ::ship=(unit @p)
                            database           ::database=@tas
                            %sys               ::namespace=@tas
                            %namespaces        ::name=@tas
                            ==
                        %namespace  ::column=@tas
                        ~  ::alias=(unit @t)
                    :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
                            ~                  ::ship=(unit @p)
                            database           ::database=@tas
                            %sys               ::namespace=@tas
                            %namespaces        ::name=@tas
                            ==
                        %tmsp                ::column=@tas
                        ~                    ::alias=(unit @t)
                    ==
            :~      ::order-by=(list ordering-column)
                :+  %ordering-column
                    :^  %qualified-column    ::qualified-column
                    :*  %qualified-object  ::qualifier
                        ~            ::ship=(unit @p)
                        database     ::database=@tas
                        %sys         ::namespace=@tas
                        %namespaces  ::name=@tas
                        ==
                    %namespace  ::column=@tas
                    ~    ::alias=(unit @t)
                    %.y  ::ascending=?
                ==
            ==
        ~
        ~
::
++  sys-tables-view
    |=  [db=@tas provenance=path tmsp=@da]
    ^-  view
    :*  %view
        provenance                     ::provenance=path
        tmsp                           ::tmsp=@da
        :+  %transform                 ::transform
            ~                              ::ctes=(list cte)
            (sys-tables-query db)          ::query
        :~  [%column %namespace ~.tas] ::columns=(list column)
            [%column %name ~.tas] 
            [%column %ship ~.p] 
            [%column %agent ~.tas] 
            [%column %tmsp ~.da] 
            [%column %row-count ~.ud] 
            [%column %clustered ~.f] 
            [%column %key-ordinal ~.ud] 
            [%column %key ~.tas] 
            [%column %key-ascending ~.f] 
            [%column %col-ordinal ~.ud]
            [%column %col-name ~.tas]
            [%column %col-type ~.tas]
           ==
        ~                              ::ordering=(list column-order)
        ==
++  sys-tables-query
    |=  database=@tas
    ^-  (tree set-function:ast)
    :+  :*  %query
            :-  ~            ::from=(unit from)
                :+  %from
                    :+  %table-set  ::object=table-set
                        :*  %qualified-object  ::object=query-source
                            ~
                            database
                            %sys
                            %tables
                            ==
                        ~  ::alias=(unit @t)
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
                            ~           ::ship=(unit @p)
                            database    ::database=@tas
                            %sys        ::namespace=@tas
                            %tables  ::name=@tas
                            ==
                        %namespace  ::column=@tas
                        ~  ::alias=(unit @t)
                    :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
                            ~                  ::ship=(unit @p)
                            database           ::database=@tas
                            %sys               ::namespace=@tas
                            %tables            ::name=@tas
                            ==
                        %name                ::column=@tas
                        ~                    ::alias=(unit @t)
                    :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
                            ~                  ::ship=(unit @p)
                            database           ::database=@tas
                            %sys               ::namespace=@tas
                            %tables            ::name=@tas
                            ==
                        %ship                ::column=@tas
                        ~                    ::alias=(unit @t)
                    :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
                            ~                  ::ship=(unit @p)
                            database           ::database=@tas
                            %sys               ::namespace=@tas
                            %tables            ::name=@tas
                            ==
                        %agent               ::column=@tas
                        ~                    ::alias=(unit @t)
                    :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
                            ~                  ::ship=(unit @p)
                            database           ::database=@tas
                            %sys               ::namespace=@tas
                            %tables            ::name=@tas
                            ==
                        %tmsp                ::column=@tas
                        ~                    ::alias=(unit @t)
                    :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
                            ~                  ::ship=(unit @p)
                            database           ::database=@tas
                            %sys               ::namespace=@tas
                            %tables            ::name=@tas
                            ==
                        %row-count           ::column=@tas
                        ~                    ::alias=(unit @t)
                    :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
                            ~                  ::ship=(unit @p)
                            database           ::database=@tas
                            %sys               ::namespace=@tas
                            %tables            ::name=@tas
                            ==
                        %clustered           ::column=@tas
                        ~                    ::alias=(unit @t)
                    :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
                            ~                  ::ship=(unit @p)
                            database           ::database=@tas
                            %sys               ::namespace=@tas
                            %tables            ::name=@tas
                            ==
                        %key-ordinal         ::column=@tas
                        ~                    ::alias=(unit @t)
                    :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
                            ~                  ::ship=(unit @p)
                            database           ::database=@tas
                            %sys               ::namespace=@tas
                            %tables            ::name=@tas
                            ==
                        %key                 ::column=@tas
                        ~                    ::alias=(unit @t)
                    :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
                            ~                  ::ship=(unit @p)
                            database           ::database=@tas
                            %sys               ::namespace=@tas
                            %tables            ::name=@tas
                            ==
                        %key-ascending       ::column=@tas
                        ~                    ::alias=(unit @t)
                    :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
                            ~                  ::ship=(unit @p)
                            database           ::database=@tas
                            %sys               ::namespace=@tas
                            %tables            ::name=@tas
                            ==
                        %col-ordinal         ::column=@tas
                        ~                    ::alias=(unit @t)
                    :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
                            ~                  ::ship=(unit @p)
                            database           ::database=@tas
                            %sys               ::namespace=@tas
                            %tables            ::name=@tas
                            ==
                        %col-name            ::column=@tas
                        ~                    ::alias=(unit @t)
                    :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
                            ~                  ::ship=(unit @p)
                            database           ::database=@tas
                            %sys               ::namespace=@tas
                            %tables            ::name=@tas
                            ==
                        %col-type                ::column=@tas
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
                        ==
                    %key-ordinal  ::column=@tas
                    ~  ::alias=(unit @t)
                    %.y  ::ascending=?
                :+  %ordering-column
                    :^  %qualified-column    ::qualified-column
                    :*  %qualified-object  ::qualifier
                        ~           ::ship=(unit @p)
                        database    ::database=@tas
                        %sys        ::namespace=@tas
                        %tables  ::name=@tas
                        ==
                    %col-ordinal  ::column=@tas
                    ~    ::alias=(unit @t)
                    %.y  ::ascending=?
                ==
            ==
        ~
        ~
::
++  sys-columns-view
    |=  [db=@tas provenance=path tmsp=@da]
    ^-  view
    :*  %view
        provenance                     ::provenance=path
        tmsp                           ::tmsp=@da
        :+  %transform                 ::transform
            ~                              ::ctes=(list cte)
            (sys-columns-query db)         ::query
        :~  [%column %namespace ~.tas] ::columns=(list column)
            [%column %name ~.tas]  
            [%column %col-ordinal ~.ud]
            [%column %col-name ~.tas]
            [%column %col-type ~.tas]
            ==
        ~                              ::ordering=(list column-order)
        ==
++  sys-columns-query
    |=  database=@tas
    ^-  (tree set-function:ast)
    :+  :*  %query
            :-  ~          ::from=(unit from)
                :+  %from
                    :+  %table-set  ::object=table-set
                        :*  %qualified-object  ::object=query-source
                            ~
                            database
                            %sys
                            %columns
                            ==
                        ~  ::alias=(unit @t)
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
                            ~           ::ship=(unit @p)
                            database    ::database=@tas
                            %sys        ::namespace=@tas
                            %columns  ::name=@tas
                            ==
                        %namespace  ::column=@tas
                        ~  ::alias=(unit @t)
                    :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
                            ~                  ::ship=(unit @p)
                            database           ::database=@tas
                            %sys               ::namespace=@tas
                            %columns            ::name=@tas
                            ==
                        %name                ::column=@tas
                        ~                    ::alias=(unit @t)
                    :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
                            ~                  ::ship=(unit @p)
                            database           ::database=@tas
                            %sys               ::namespace=@tas
                            %columns            ::name=@tas
                            ==
                        %col-ordinal         ::column=@tas
                        ~                    ::alias=(unit @t)
                    :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
                            ~                  ::ship=(unit @p)
                            database           ::database=@tas
                            %sys               ::namespace=@tas
                            %columns            ::name=@tas
                            ==
                        %col-name            ::column=@tas
                        ~                    ::alias=(unit @t)
                    :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
                            ~                  ::ship=(unit @p)
                            database           ::database=@tas
                            %sys               ::namespace=@tas
                            %columns            ::name=@tas
                            ==
                        %col-type                ::column=@tas
                        ~                    ::alias=(unit @t)
                    ==
            :~      ::order-by=(list ordering-column)
                :+  %ordering-column
                    :^  %qualified-column    ::qualified-column
                    :*  %qualified-object  ::qualifier
                        ~           ::ship=(unit @p)
                        database    ::database=@tas
                        %sys        ::namespace=@tas
                        %columns    ::name=@tas
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
                        ==
                    %col-ordinal  ::column=@tas
                    ~  ::alias=(unit @t)
                    %.y  ::ascending=?
                ==
            ==
        ~
        ~
::
++  sys-sys-log-view
    |=  [database=@tas provenance=path tmsp=@da]
    ^-  view
    :*  %view
        provenance                     ::provenance=path
        tmsp                           ::tmsp=@da
        :+  %transform                 ::transform
            ~                              ::ctes=(list cte)
            (sys-sys-log-query database)   ::query
        :~  [%column %tmsp ~.da]       ::columns=(list column)
            [%column %agent ~.tas]
            [%column %component ~.tas]
            [%column %name ~.tas]
            ==
        ~                              ::ordering=(list column-order)
        ==
++  sys-sys-log-query
    |=  database=@tas
    ^-  (tree set-function:ast)
    :+  :*  %query
            :-  ~            ::from=(unit from)
                :+  %from
                    :+  %table-set  ::object=table-set
                        :*  %qualified-object  ::object=query-source
                            ~
                            database
                            %sys
                            %sys-log
                            ==
                        ~  ::alias=(unit @t)
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
                            ~                  ::ship=(unit @p)
                            database           ::database=@tas
                            %sys               ::namespace=@tas
                            %sys-log           ::name=@tas
                            ==
                        %tmsp                ::column=@tas
                        ~                    ::alias=(unit @t)
                    :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
                            ~                  ::ship=(unit @p)
                            database           ::database=@tas
                            %sys               ::namespace=@tas
                            %sys-log           ::name=@tas
                            ==
                        %agent               ::column=@tas
                        ~                    ::alias=(unit @t)
                    :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
                            ~                  ::ship=(unit @p)
                            database           ::database=@tas
                            %sys               ::namespace=@tas
                            %sys-log           ::name=@tas
                            ==
                        %component           ::column=@tas
                        ~                    ::alias=(unit @t)
                    :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
                            ~                  ::ship=(unit @p)
                            database           ::database=@tas
                            %sys               ::namespace=@tas
                            %sys-log            ::name=@tas
                            ==
                        %name                ::column=@tas
                        ~                    ::alias=(unit @t)
                    ==
            :~      ::order-by=(list ordering-column)
                :+  %ordering-column
                    :^  %qualified-column    ::qualified-column
                    :*  %qualified-object  ::qualifier
                        ~           ::ship=(unit @p)
                        database    ::database=@tas
                        %sys        ::namespace=@tas
                        %sys-log    ::name=@tas
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
                        ==
                    %name  ::column=@tas
                    ~  ::alias=(unit @t)
                    %.y  ::ascending=?
                ==
            ==
        ~
        ~
::
++  sys-data-log-view
    |=  [database=@tas provenance=path tmsp=@da]
    ^-  view
    :*  %view
        provenance                     ::provenance=path
        tmsp                           ::tmsp=@da
        :+  %transform                 ::transform
            ~                              ::ctes=(list cte)
            (sys-data-log-query database)  ::query
        :~  [%column %tmsp ~.da]        ::columns=(list column)
            [%column %ship ~.p]
            [%column %agent ~.tas]
            [%column %namespace ~.tas]
            [%column %table ~.tas]
            ==
        ~                              ::ordering=(list column-order)
        ==
++  sys-data-log-query
    |=  database=@tas
    ^-  (tree set-function:ast)
    :+  :*  %query
            :-  ~           ::from=(unit from)
                :+  %from
                    :+  %table-set  ::object=table-set
                        :*  %qualified-object  ::object=query-source
                            ~
                            database
                            %sys
                            %data-log
                            ==
                        ~                      ::alias=(unit @t)
                    ~               ::joins=(list joined-object)
            ~            ::scalars=(list scalar-function)
            ~            ::predicate=(unit predicate)
            ~            ::group-by=(list grouping-column)
            ~            ::having=(unit predicate)
            :^  %select  ::selection=select
                ~               ::top=(unit @ud)
                ~               ::bottom=(unit @ud)
                :~  :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
                            ~                  ::ship=(unit @p)
                            database           ::database=@tas
                            %sys               ::namespace=@tas
                            %data-log           ::name=@tas
                            ==
                        %tmsp                ::column=@tas
                        ~                    ::alias=(unit @t)
                    :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
                            ~                  ::ship=(unit @p)
                            database           ::database=@tas
                            %sys               ::namespace=@tas
                            %data-log           ::name=@tas
                            ==
                        %ship                ::column=@tas
                        ~                    ::alias=(unit @t)
                    :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
                            ~                  ::ship=(unit @p)
                            database           ::database=@tas
                            %sys               ::namespace=@tas
                            %data-log           ::name=@tas
                            ==
                        %agent               ::column=@tas
                        ~                    ::alias=(unit @t)
                    :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
                            ~                  ::ship=(unit @p)
                            database           ::database=@tas
                            %sys               ::namespace=@tas
                            %data-log           ::name=@tas
                            ==
                        %namespace           ::column=@tas
                        ~                    ::alias=(unit @t)
                    :^  %qualified-column    ::qualified-column
                        :*  %qualified-object  ::qualifier
                            ~                  ::ship=(unit @p)
                            database           ::database=@tas
                            %sys               ::namespace=@tas
                            %data-log            ::name=@tas
                            ==
                        %table                ::column=@tas
                        ~                    ::alias=(unit @t)
                    ==
            :~      ::order-by=(list ordering-column)
                :+  %ordering-column
                    :^  %qualified-column    ::qualified-column
                    :*  %qualified-object  ::qualifier
                        ~                      ::ship=(unit @p)
                        database               ::database=@tas
                        %sys                   ::namespace=@tas
                        %data-log              ::name=@tas
                        ==
                    %tmsp                  ::column=@tas
                    ~                      ::alias=(unit @t)
                    %.n                    ::ascending=?
                :+  %ordering-column
                    :^  %qualified-column    ::qualified-column
                    :*  %qualified-object  ::qualifier
                        ~                      ::ship=(unit @p)
                        database               ::database=@tas
                        %sys                   ::namespace=@tas
                        %data-log              ::name=@tas
                        ==
                    %namespace             ::column=@tas
                    ~                      ::alias=(unit @t)
                    %.y                    ::ascending=?
                :+  %ordering-column
                    :^  %qualified-column    ::qualified-column
                    :*  %qualified-object  ::qualifier
                        ~           ::ship=(unit @p)
                        database    ::database=@tas
                        %sys        ::namespace=@tas
                        %data-log   ::name=@tas
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
    ?~  set-functions.transform.v  ~|("can't get here" !!)
    =/  qsf=set-function:ast  `set-function:ast`n.set-functions.transform.v
    ?~  +>+>+>+.qsf  v
    v(ordering (make-ordering columns.v +>+>+>+.qsf))
::
++  populate-system-view
    |=  [=databases =database =schema =view name=@tas]
    ::^-  view
  ::  =/  =tables     tables.sys
  ::  =/  udata=data  (get-data now.bowl content.db)
    ?+  name  ~|("unknown system view" !!)
    ::
    %databases
      =/  dbes             (turn ~(val by databases) sys-view-databases)
      (sort `(list (list @))`(zing dbes) ~(order order-row ordering.view))
    ::
    %namespaces  !!
        ::      =/  ns-order    ~[[%t %.y 0]]
        ::      =/  namespaces  (~(urn by namespaces.sys) |=([k=@tas v=@da] ~[k v]))
        ::      :^
        ::      %result-set
        ::      `@ta`(crip (weld (trip database.q) ".sys.namespaces"))
        ::      ~[[%namespace %tas] [%tmsp %da]]
        ::      (sort `(list (list @))`~(val by namespaces) ~(order order-row ns-order))
    ::
    %tables  !!
        ::      =/  tables-order  ~[[%t %.y 0] [%t %.y 1] [%ud %.y 7] [%ud %.y 10]]
        ::      =/  tbls  (turn ~(tap by files.udata) ~(foo sys-view-tables tables))
        ::      :^
        ::      %result-set
        ::      `@ta`(crip (weld (trip database.q) ".sys.tables"))
        ::       :~  [%namespace %tas] 
        ::           [%name %tas] 
        ::           [%ship %p] 
        ::           [%agent %tas] 
        ::           [%tmsp %da] 
        ::           [%row-count %ud] 
        ::           [%clustered %f] 
        ::           [%key-ordinal %ud] 
        ::           [%key %tas] 
        ::           [%key-ascending %f] 
        ::           [%col-ordinal %ud]
        ::           [%col-name %tas]
        ::           [%col-type %tas]
        ::           ==
        ::      (sort `(list (list @))`(zing tbls) ~(order order-row tables-order))
    ::
    %columns  !!
        ::      =/  columns-order  ~[[%t %.y 0] [%t %.y 1] [%ud %.y 2]]
        ::      =/  columns  (turn ~(tap by files.udata) ~(foo sys-view-columns tables))
        ::      :^
        ::      %result-set
        ::      `@ta`(crip (weld (trip database.q) ".sys.columns"))
        ::       :~  [%namespace %tas] 
        ::           [%name %tas]  
        ::           [%col-ordinal %ud]
        ::           [%col-name %tas]
        ::           [%col-type %tas]
        ::           ==
        ::      (sort `(list (list @))`(zing columns) ~(order order-row columns-order))
    ::
    %sys-log  !!
        ::      :: to do: rewrite as jagged when architecture available
        ::      =/  sys-order   ~[[%da %.n 0] [%t %.y 2] [%t %.y 3]]
        ::      =/  sys=(list schema)
        ::            (turn (tap:schema-key sys.db) |=(b=[@da schema] +.b))
        ::      =/  namespaces  (zing (turn sys sys-view-sys-log-ns))
        ::      =/  tbls        (zing (turn sys sys-view-sys-log-tbl))
        ::      =/  log         (weld `(list (list @))`namespaces `(list (list @))`tbls)
        ::      :^
        ::      %result-set
        ::      `@ta`(crip (weld (trip database.q) ".sys.sys-log"))
        ::      ~[[%tmsp %da] [%agent %tas] [%component %tas] [%name %tas]]
        ::      (sort `(list (list @))`log ~(order order-row sys-order))
    ::
    %data-log  !!
        ::      =/  data-order   ~[[%da %.n 0] [%t %.y 3] [%t %.y 4]]
        ::      =/  tbls  
        ::            %-  zing  
        ::                %+  turn  (turn (tap:data-key content.db) |=(b=[@da data] +.b)) 
        ::                          sys-view-data-log
        ::      :^
        ::      %result-set
        ::      `@ta`(crip (weld (trip database.q) ".sys.data-log"))
        ::      ~[[%tmsp %da] [%ship %p] [%agent %tas] [%namespace %tas] [%table %tas]]
        ::      (sort `(list (list @))`tbls ~(order order-row data-order))
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
    |=  [k=[@tas @tas] =file]  !!
    ::      ^-  (list (list @))
    ::      =/  aa=(list @)  :~  -.k
    ::                          +.k
    ::                          ship.file
    ::                          (crip (spud provenance.file))
    ::                          tmsp.file
    ::                          length.file
    ::                          clustered.file
    ::                        ==
    ::      =/  tbl  (~(got by tables) [-.k +.k])
    ::      =/  keys
    ::        %^  spin  columns.pri-indx.tbl
    ::            1
    ::            |=([n=ordered-column:ast a=@] [~[a name.n ascending.n] +(a)])
    ::      =/  columns  
    ::        %^  spin  columns.tbl
    ::            1
    ::            |=([n=column:ast a=@] [`(list @)`~[a name.n type.n] +(a)])
    ::      =/  aaa=(list (list @))  (turn p.keys |=(a=(list @) (weld aa a)))
    ::      =/  b=(list (list @))  ~
    ::      |-  ?~  aaa  b
    ::      %=  $
    ::      b  %+  weld 
    ::             (turn p.columns |=(a=(list @) (weld `(list @)`-.aaa `(list @)`a)))
    ::             b
    ::      aaa  +.aaa
    ::      ==
    --

++  sys-view-columns
  |_  tables=(map [@tas @tas] table)
  ++  foo
    |=  [k=[@tas @tas] =file]  !!
    ::      ^-  (list (list @))
    ::      =/  aa=(list @)  ~[-.k +.k]
    ::      =/  tbl  (~(got by tables) [-.k +.k])
    ::      =/  columns  
    ::        %^  spin  columns.tbl
    ::            1
    ::            |=([n=column:ast a=@] [`(list @)`~[a name.n type.n] +(a)])
    ::     (turn p.columns |=(a=(list @) (weld aa a)))
    --
++  sys-view-sys-log-ns
  |=  a=schema  !!
    ::    ^-  (list (list @))
    ::    =/  namespaces  %+  skim  
    ::                    ~(val by (~(urn by namespaces.a) |=([k=@tas v=@da] [k v])))
    ::                    |=(b=[ns=@tas tmsp=@da] =(tmsp.a tmsp.b))
    ::    %+  turn  namespaces
    ::      |=([ns=@tas tmsp=@da] ~[tmsp.a (crip (spud provenance.a)) %namespace ns])
++  sys-view-data-log
  |=  a=data  !!
    ::    ^-  (list (list @))
    ::    =/  tbls  %+  skim
    ::                  %~  val  by
    ::                      (~(urn by files.a) |=([k=[@tas @tas] =file] [k file]))
    ::                  |=(b=[k=[@tas @tas] =file] =(tmsp.a tmsp.file.b))
    ::    %+  turn
    ::          tbls
    ::   |=([k=[@tas @tas] =file] ~[tmsp.a ship.a (crip (spud provenance.a)) -.k +.k])
    ::  ++  sys-view-sys-log-tbl
    ::    |=  a=schema
    ::    ^-  (list (list @))
    ::    =/  tbls  %+  skim
    ::                  %~  val  by
    ::                      (~(urn by tables.a) |=([k=[@tas @tas] =table] [k table]))
    ::                  |=(b=[k=[@tas @tas] =table] =(tmsp.a tmsp.table.b))
    ::    %+  turn  tbls
    ::      |=([k=[@tas @tas] =table] ~[tmsp.a (crip (spud provenance.a)) -.k +.k])
--
