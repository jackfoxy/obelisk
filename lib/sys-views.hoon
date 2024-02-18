/-  ast, *obelisk
|%
++  sys-sys-dbs-view
    |=  [provenance=path tmsp=@da]
    ^-  view
    :*  %view
        provenance                     ::provenance=path
        tmsp                           ::tmsp=@da
        %.y                            ::is-dirty=?
        %.n                            ::is-tombstoned=?
        :+  %transform                 ::transform
            ~                              ::ctes=(list cte)
            sys-sys-dbs-query              ::query
        ~                              ::content=(list (list cell))
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
        %.y                            ::is-dirty=?
        %.n                            ::is-tombstoned=?
        :+  %transform                 ::transform
            ~                              ::ctes=(list cte)
            (sys-namespaces-query db)      ::query
        ~                              ::content=(list (list cell))
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
        %.y                            ::is-dirty=?
        %.n                            ::is-tombstoned=?
        :+  %transform                 ::transform
            ~                              ::ctes=(list cte)
            (sys-tables-query db)          ::query
        ~                              ::content=(list (list cell))
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
        %.y                            ::is-dirty=?
        %.n                            ::is-tombstoned=?
        :+  %transform                 ::transform
            ~                              ::ctes=(list cte)
            (sys-columns-query db)         ::query
        ~                              ::content=(list (list cell))
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
        %.y                            ::is-dirty=?
        %.n                            ::is-tombstoned=?
        :+  %transform                 ::transform
            ~                              ::ctes=(list cte)
            (sys-sys-log-query database)   ::query
        ~                              ::content=(list (list cell))
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
        %.y                            ::is-dirty=?
        %.n                            ::is-tombstoned=?
        :+  %transform                 ::transform
            ~                              ::ctes=(list cte)
            (sys-data-log-query database)  ::query
        ~                              ::content=(list (list cell))
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
--
