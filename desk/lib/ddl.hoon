/-  ast, *obelisk, *server-state-1
/+  *utils
|_  [state=server =bowl:gall]
::
++  license
  ::  MIT+n license
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
::
++  create-ns
  |=  $:  =create-namespace:ast
          next-schemas=(map @tas @da)
          next-data=(map @tas @da)
      ==
  ^-  [cmd-result:ast (map @tas @da) server]
  ?:  =(database-name.create-namespace %sys)
        ~|("cannot create namespace in sys database" !!)
  =/  db  ~|  "CREATE NAMESPACE: database {<database-name.create-namespace>} ".
              "does not exist"
                 (~(got by state) database-name.create-namespace)
  =/  sys-time  (set-tmsp as-of.create-namespace now.bowl)
  =/  nxt-schema=schema
        ~|  "CREATE NAMESPACE: namespace {<name.create-namespace>} as-of ".
            "schema time out of order"
            %:  get-next-schema  sys.db
                                 next-schemas
                                 sys-time
                                 database-name.create-namespace
                                 ==
  =/  dummy
        ~|  "CREATE NAMESPACE: namespace {<name.create-namespace>} as-of ".
            "content time out of order"
          %:  get-next-data  content.db  :: for date checking purposes
                              next-data
                              sys-time
                              database-name.create-namespace
                              ==
  =.  namespaces.nxt-schema
        ~|  "CREATE NAMESPACE: namespace {<name.create-namespace>} ".
            "already exists"
        %:  map-insert
            namespaces.nxt-schema
            name.create-namespace
            sys-time
        ==
  =.  tmsp.nxt-schema        sys-time
  =.  provenance.nxt-schema  sap.bowl
  ::
  =.  sys.db        (put:schema-key sys.db sys-time nxt-schema)
  =.  event-log.db  :-  :*  %sys-log-event
                            sys-time
                            sap.bowl
                            %create
                            %namespace
                            database-name.create-namespace
                            `name.create-namespace
                            ~
                            ~
                            ~
                            ~
                            ~
                            ==
                        event-log.db
  =.  view-cache.db  (upd-view-caches state db sys-time ~ %create-namespace)
  ::
  :+  :-  %results
          :~  [%action (crip "CREATE NAMESPACE {<name.create-namespace>}")]
              [%server-time now.bowl]
              [%schema-time sys-time]
              ==
      (~(put by next-schemas) database-name.create-namespace sys-time)
      (~(put by state) name.db db) 
::
++  alter-ns
  |=  $:  a=alter-namespace:ast
          next-schemas=(map @tas @da)
          next-data=(map @tas @da)
          ==
  ^-  [cmd-result:ast (map @tas @da) (map @tas @da) server]
  ?:  !=(%table table-or-view.a)
    ~|("ALTER NAMESPACE: only table transfers are implemented" !!)
  =/  src=qualified-table:ast  qualified-table.a
  ?:  =(%sys database.src)
    ~|("ALTER NAMESPACE: cannot transfer table out of %sys database" !!)
  ?:  =(%sys database-name.a)
    ~|("ALTER NAMESPACE: cannot transfer table into %sys database" !!)
  ?:  =(%sys namespace.src)
    ~|("ALTER NAMESPACE: cannot transfer table out of %sys namespace" !!)
  ?:  =(%sys target-namespace.a)
    ~|("ALTER NAMESPACE: cannot transfer table into %sys namespace" !!)
  =/  same-db=?  =(database.src database-name.a)
  =/  sys-time  (set-tmsp as-of.a now.bowl)
  =/  src-db  ~|  "ALTER NAMESPACE: database {<database.src>} does not exist"
                  (~(got by state) database.src)
  =/  tgt-db  ~|  "ALTER NAMESPACE: database {<database-name.a>} does not exist"
                  (~(got by state) database-name.a)
  =/  src-schema=schema  +:(need (pry:schema-key sys.src-db))
  =/  tgt-schema=schema  +:(need (pry:schema-key sys.tgt-db))
  ?.  (gth sys-time tmsp.src-schema)
    ~|  "ALTER NAMESPACE: {<name.src>} as-of schema time out of order"
        !!
  ?.  ?|(same-db (gth sys-time tmsp.tgt-schema))
    ~|  "ALTER NAMESPACE: {<name.src>} as-of schema time out of order"
        !!
  =/  src-data=data  +:(need (pry:data-key content.src-db))
  =/  tgt-data=data  +:(need (pry:data-key content.tgt-db))
  ?.  (gth sys-time tmsp.src-data)
    ~|  "ALTER NAMESPACE: {<name.src>} as-of content time out of order"
        !!
  ?.  ?|(same-db (gth sys-time tmsp.tgt-data))
    ~|  "ALTER NAMESPACE: {<name.src>} as-of content time out of order"
        !!
  ?.  (~(has by namespaces.tgt-schema) target-namespace.a)
    ~|  "ALTER NAMESPACE: namespace {<target-namespace.a>} does not exist"
        !!
  =/  src-key  [namespace.src name.src]
  =/  tgt-key  [target-namespace.a name.src]
  =/  tbl=table
        ~|  "ALTER NAMESPACE: table {<namespace.src>}.{<name.src>} does not exist"
        (~(got by tables.src-schema) src-key)
  ?:  (~(has by tables.tgt-schema) tgt-key)
    ~|  "ALTER NAMESPACE: table {<target-namespace.a>}.{<name.src>} ".
        "already exists"
        !!
  =/  fil=file
        ~|  "ALTER NAMESPACE: data for table {<namespace.src>}.{<name.src>} ".
            "does not exist"
        (~(got by files.src-data) src-key)
  ?:  ?&  !same-db
          ?|  (fk-outbound-index-has-entries outbound-fk-index.tbl)
              !=(~ foreign-constraints.fil)
              ==
          ==
    ~|("ALTER NAMESPACE: FOREIGN KEY cross-database transfer not allowed" !!)
  =/  event=sys-log-event
        :*  %sys-log-event
            sys-time
            sap.bowl
            %alter
            %table
            database.src
            `namespace.src
            `name.src
            `database-name.a
            `target-namespace.a
            `name.src
            ~
            ==
  =.  tmsp.tbl        sys-time
  =.  provenance.tbl  sap.bowl
  =.  tmsp.fil        sys-time
  =.  provenance.fil  sap.bowl
  =.  ship.fil        src.bowl
  ?:  same-db
    =.  tables.src-schema
          %:  map-insert  tables.src-schema
                          tgt-key
                          tbl
                          ==
    =.  tmsp.src-schema        sys-time
    =.  provenance.src-schema  sap.bowl
    =.  files.src-data
          %:  map-insert  files.src-data
                          tgt-key
                          fil
                          ==
    =/  transfer-work
          %:  rewrite-table-rename-fks
                src-key
                tgt-key
                tbl
                tables.src-schema
                files.src-data
                ==
    =.  tables.src-schema  -.transfer-work
    =.  files.src-data     +.transfer-work
    =/  old-src-tbl=table  (~(got by tables.src-schema) src-key)
    =.  outbound-fk-index.old-src-tbl  ~
    =.  tables.src-schema  (~(put by tables.src-schema) src-key old-src-tbl)
    =/  old-src-fil=file  (~(got by files.src-data) src-key)
    =.  foreign-constraints.old-src-fil  ~
    =.  files.src-data  (~(put by files.src-data) src-key old-src-fil)
    =.  tmsp.src-data        sys-time
    =.  provenance.src-data  sap.bowl
    =.  ship.src-data        src.bowl
    =.  sys.src-db        (put:schema-key sys.src-db sys-time src-schema)
    =.  content.src-db    (put:data-key content.src-db sys-time src-data)
    =.  event-log.src-db  [event event-log.src-db]
    =.  view-cache.src-db  (upd-view-caches state src-db sys-time ~ %alter-namespace)
    =.  state             (~(put by state) database.src src-db)
    =.  state             (update-sys state sys-time)
    :^  :-  %results
            :~  [%action (crip "ALTER NAMESPACE TRANSFER TABLE {<name.src>}")]
                [%server-time now.bowl]
                [%schema-time sys-time]
                [%data-time sys-time]
                ==
        (~(put by next-schemas) database.src sys-time)
        (~(put by next-data) database.src sys-time)
        state
  =.  tmsp.src-schema        sys-time
  =.  provenance.src-schema  sap.bowl
  =.  event-log.src-db       [event event-log.src-db]
  =.  view-cache.src-db
        %^  next-view-cache-keys  src-db
                                  sys-time
                                  ~[[%sys %sys-log]]
  =.  tables.tgt-schema
        %:  map-insert  tables.tgt-schema
                        tgt-key
                        tbl
                        ==
  =.  tmsp.tgt-schema        sys-time
  =.  provenance.tgt-schema  sap.bowl
  =.  files.tgt-data
        %:  map-insert  files.tgt-data
                        tgt-key
                        fil
                        ==
  =.  tmsp.tgt-data        sys-time
  =.  provenance.tgt-data  sap.bowl
  =.  ship.tgt-data        src.bowl
  =.  event-log.tgt-db     [event event-log.tgt-db]
  =.  sys.src-db      (put:schema-key sys.src-db sys-time src-schema)
  =.  sys.tgt-db      (put:schema-key sys.tgt-db sys-time tgt-schema)
  =.  content.tgt-db  (put:data-key content.tgt-db sys-time tgt-data)
  =.  view-cache.tgt-db  (upd-view-caches state tgt-db sys-time ~ %alter-namespace)
  =.  state  (~(put by state) database.src src-db)
  =.  state  (~(put by state) database-name.a tgt-db)
  =.  state  (update-sys state sys-time)
  :^  :-  %results
          :~  [%action (crip "ALTER NAMESPACE TRANSFER TABLE {<name.src>}")]
              [%server-time now.bowl]
              [%schema-time sys-time]
              [%data-time sys-time]
              ==
      (~(put by (~(put by next-schemas) database.src sys-time)) database-name.a sys-time)
      (~(put by next-data) database-name.a sys-time)
      state
::
++  create-tbl
  |=  $:  =create-table:ast
          next-schemas=(map @tas @da)
          next-data=(map @tas @da)
          ==
  ^-  [cmd-result:ast (map @tas @da) (map @tas @da) server]
  ?:  =(database.qualified-table.create-table %sys)
        ~|("cannot create table in %sys database" !!)
  =/  db  ~|  "CREATE TABLE: database ".
              "{<database.qualified-table.create-table>} does not exist"
              (~(got by state) database.qualified-table.create-table)
  =/  sys-time  (set-tmsp as-of.create-table now.bowl)
  =/  nxt-schema=schema
        ~|  "CREATE TABLE: {<name.qualified-table.create-table>} as-of schema ".
            "time out of order"
            %:  get-next-schema  sys.db
                                 next-schemas
                                 sys-time
                                 database.qualified-table.create-table
                                 ==
  =/  nxt-data=data
        ~|  "CREATE TABLE: {<name.qualified-table.create-table>} as-of data ".
            "time out of order"
            %:  get-next-data  content.db
                               next-data
                               sys-time
                               database.qualified-table.create-table
                               ==
  ::
  ?.  (~(has by namespaces.nxt-schema) namespace.qualified-table.create-table)
    ~|  "CREATE TABLE: namespace {<namespace.qualified-table.create-table>} ".
        "does not exist"
        !!
  =/  col-set  (name-set (silt columns.create-table))
  ?.  =((lent columns.create-table) ~(wyt in col-set))
    ~|("CREATE TABLE: duplicate column names {<columns.create-table>}" !!)
  =/  key-col-set  (name-set (silt pri-indx.create-table))
  =/  key-count  ~(wyt in key-col-set)
  ?.  =((lent pri-indx.create-table) key-count)
    ~|  "CREATE TABLE: duplicate column names in key {<pri-indx.create-table>}"
        !!
  ?.  =(key-count ~(wyt in (~(int in col-set) key-col-set)))
    ~|  "CREATE TABLE: key column not in column definitions ".
        "{<pri-indx.create-table>}"
        !!
  ::
  =/  column-look-up  (malt (spun columns.create-table mk-col-lu-data))
  ::
  =/  table
        :*  %table
            sap.bowl
            sys-time
            column-look-up
            (mk-unqualified-typ-addr-lookup (addr-columns columns.create-table))
            [%index %.y (mk-key-column column-look-up pri-indx.create-table)]
            (addr-columns columns.create-table)
            ~
            ~
            ==
  =/  tables
    ~|  "CREATE TABLE: {<name.qualified-table.create-table>} ".
        "exists in {<namespace.qualified-table.create-table>}"
    %:  map-insert
        tables.nxt-schema
        :-  namespace.qualified-table.create-table
            name.qualified-table.create-table
        table
    ==
  =.  tables.nxt-schema      tables
  =.  tmsp.nxt-schema        sys-time
  =.  provenance.nxt-schema  sap.bowl
  ::
  =/  file  :*  %file
                src.bowl
                sap.bowl
                sys-time
                0
                ~
                ~
                ~
                ==
  =/  files
    ~|  "CREATE TABLE: {<name.qualified-table.create-table>} ".
        "exists in {<namespace.qualified-table.create-table>}"
    %:  map-insert
        files.nxt-data
        :-  namespace.qualified-table.create-table
            name.qualified-table.create-table
        file
    ==
  =.  files.nxt-data       files
  =.  ship.nxt-data        src.bowl
  =.  provenance.nxt-data  sap.bowl
  =.  tmsp.nxt-data        sys-time
  ::
  =/  fk-work
        =/  source-key  [namespace.qualified-table.create-table name.qualified-table.create-table]
        =/  out-tables  tables.nxt-schema
        =/  out-files   files.nxt-data
        =/  fks=(list foreign-key:ast)  foreign-keys.create-table
        |-
        ?~  fks  [out-tables out-files]
        =/  fk=foreign-key:ast  i.fks
        =/  dummy  (validate-create-fk source-key namespaces.nxt-schema out-tables out-files fk)
        =/  parent-key=[@tas @tas]
              [namespace.reference-table.fk name.reference-table.fk]
        =/  child-table  (~(got by out-tables) source-key)
        =/  child-file   (~(got by out-files) source-key)
        =/  parent-file  (~(got by out-files) parent-key)
        =/  registered
              (register-fk fk child-table child-file parent-file sys-time)
        %=  $
          fks         t.fks
          out-tables  (~(put by out-tables) source-key child.registered)
          out-files   (~(put by out-files) parent-key parent.registered)
        ==
  =.  tables.nxt-schema  -.fk-work
  =.  files.nxt-data     +.fk-work
  ::
  =.  sys.db        (put:schema-key sys.db sys-time nxt-schema)
  =.  content.db    (put:data-key content.db sys-time nxt-data)
  =.  event-log.db  :-  :*  %sys-log-event
                            sys-time
                            sap.bowl
                            %create
                            %table
                            database.qualified-table.create-table
                            `namespace.qualified-table.create-table
                            `name.qualified-table.create-table
                            ~
                            ~
                            ~
                            ~
                            ==
                        event-log.db
  =.  view-cache.db  (upd-view-caches state db sys-time ~ %create-table)
  =.  state          (update-sys state sys-time)
  ::
  :^  :-  %results
          :~  :-  %action
                  %-  crip
                  "CREATE TABLE {<name.qualified-table.create-table>}"
              [%server-time now.bowl]
              [%schema-time sys-time]
              ==
      (~(put by next-schemas) database.qualified-table.create-table sys-time)
      (~(put by next-data) database.qualified-table.create-table sys-time)
      (~(put by state) name.db db)
::
++  alter-tbl
  |=  $:  a=alter-table:ast
          next-schemas=(map @tas @da)
          next-data=(map @tas @da)
          ==
  ^-  [cmd-result:ast (map @tas @da) (map @tas @da) server]
  ?:  =(database.qualified-table.a %sys)
        ~|("cannot alter table in %sys database" !!)
  =/  db  ~|  "ALTER TABLE: database ".
              "{<database.qualified-table.a>} does not exist"
              (~(got by state) database.qualified-table.a)
  =/  sys-time  (set-tmsp as-of.a now.bowl)
  =/  nxt-schema=schema
        ~|  "ALTER TABLE: {<name.qualified-table.a>} as-of schema ".
            "time out of order"
            %:  get-next-schema  sys.db
                                 next-schemas
                                 sys-time
                                 database.qualified-table.a
                                 ==
  =/  nxt-data=data
        ~|  "ALTER TABLE: {<name.qualified-table.a>} as-of data ".
            "time out of order"
            %:  get-next-data  content.db
                                next-data
                                sys-time
                                database.qualified-table.a
                                ==
  ?.  (~(has by namespaces.nxt-schema) namespace.qualified-table.a)
    ~|  "ALTER TABLE: namespace {<namespace.qualified-table.a>} ".
        "does not exist"
        !!
  =/  src-key  [namespace.qualified-table.a name.qualified-table.a]
  =/  tbl=table
        ~|  "ALTER TABLE: {<name.qualified-table.a>} does not exist in ".
            "{<namespace.qualified-table.a>}"
        (~(got by tables.nxt-schema) src-key)
  =/  fil=file
        ~|  "ALTER TABLE: {<name.qualified-table.a>} does not exist in ".
            "{<namespace.qualified-table.a>}"
        (~(got by files.nxt-data) src-key)
  =/  old-outgoing-fks=(list outbound-fk-entry)
        (collect-outbound-fks outbound-fk-index.tbl)
  =/  target-name=@tas  ?~  new-name.a  name.qualified-table.a  u.new-name.a
  =/  target-key  [namespace.qualified-table.a target-name]
  ?:  ?&(?=(^ new-name.a) (~(has by tables.nxt-schema) target-key))
    ~|  "ALTER TABLE: {<target-name>} exists in ".
        "{<namespace.qualified-table.a>}"
        !!
  ::
  =/  dummy  %+  assert-no-dups  "ALTER TABLE: duplicate column names ".
                                 "in COLUMNS"
                                 columns.a
  =/  dummy  %+  assert-no-dups  "ALTER TABLE: duplicate column names in key"
                                 (col-names pri-indx.a)
  =/  dummy  %+  assert-no-dups  "ALTER TABLE: duplicate column names"
                                 (turn add-columns.a |=(c=column:ast name.c))
  =/  dummy  %+  assert-no-dups  "ALTER TABLE: duplicate column names"
                                 drop-columns.a
  =/  dummy  %+  assert-no-dups  "ALTER TABLE: duplicate column names"
                                 (turn alter-columns.a |=(c=column:ast name.c))
  =/  dummy  %+  assert-no-dups  "ALTER TABLE: duplicate column names"
                                 (turn rename-columns.a |=(p=[@tas @tas] -.p))
  =/  dummy  %+  assert-no-dups  "ALTER TABLE: duplicate column names"
                                 (turn rename-columns.a |=(p=[@tas @tas] +.p))
  =/  dummy
        %:  assert-fk-column-change-allowed
              tbl
              fil
              drop-columns.a
              alter-columns.a
              ==
  ::
  =/  old-cols=(list column:ast)  columns.tbl
  =/  old-col-map  (column-map old-cols)
  =/  work=[cols=(list column:ast) cmap=(map @tas column:ast)]
        [old-cols old-col-map]
  =.  work  %:  apply-add-columns     name.qualified-table.a
                                      cols.work
                                      cmap.work
                                      add-columns.a
                                      ==
  =.  work  %:  apply-drop-columns    name.qualified-table.a
                                      cols.work
                                      cmap.work
                                      drop-columns.a
                                      ==
  =.  work  %:  apply-rename-columns  name.qualified-table.a
                                      cols.work
                                      cmap.work
                                      rename-columns.a
                                      ==
  =.  work  %:  apply-alter-columns   name.qualified-table.a
                                      cols.work
                                      cmap.work
                                      alter-columns.a
                                      ==
  ::
  =/  final-cols=(list column:ast)
    ?~  columns.a
      cols.work
    (order-columns name.qualified-table.a cmap.work old-cols columns.a)
  =/  shape-change=?  ?|  !=(add-columns.a ~)
                          !=(drop-columns.a ~)
                          !=(rename-columns.a ~)
                          ==
  =/  type-change=?   !=(alter-columns.a ~)
  =/  cols-changed=?  ?|(shape-change type-change !=(columns.a ~))
  =/  rebuilt-cols=(list column:ast)  ?:  shape-change
                                        (addr-columns final-cols)
                                      final-cols
  =/  final-lookup=column-lookup
        ?:  shape-change
          (malt (spun rebuilt-cols mk-col-lu-data))
        ?:  type-change
          (update-column-lookup-types column-lookup.tbl alter-columns.a)
        column-lookup.tbl
  =/  final-typ-addr=(map @tas typ-addr)
        ?:  shape-change
          (mk-unqualified-typ-addr-lookup rebuilt-cols)
        ?:  type-change
          (update-typ-addr-types typ-addr-lookup.tbl alter-columns.a)
        typ-addr-lookup.tbl
  ::
  =/  old-key-names=(list ordered-column:ast)
        %+  turn  key.pri-indx.tbl
                  |=(k=key-column [%ordered-column name.k ascending.k])
  =/  kept-key=(list ordered-column:ast)
        (rename-ordered-columns old-key-names rename-columns.a)
  =/  req-key=?  !=(pri-indx.a ~)
  =/  final-key-ast=(list ordered-column:ast)  ?:  req-key  pri-indx.a  kept-key
  =/  dummy  (assert-key-columns final-lookup (col-names final-key-ast))
  =/  final-key=(list key-column)  (mk-key-column final-lookup final-key-ast)
  ?:  ?&(req-key =(final-key key.pri-indx.tbl))
    ~|  "ALTER TABLE: {<name.qualified-table.a>} PRIMARY KEY does not alter ".
        "existing key"
        !!
  ::
  =/  key-change=?     !=(final-key key.pri-indx.tbl)
  ?:  ?&(req-key key-change !=(~ foreign-constraints.fil))
    ~|("ALTER TABLE: PRIMARY KEY is referenced by FOREIGN KEY" !!)
  =/  file-change=?    ?|(?=(^ new-name.a) shape-change key-change)
  =/  final-file=file  ?:  file-change  %:  alter-file  fil
                                                        add-columns.a
                                                        drop-columns.a
                                                        rename-columns.a
                                                        final-key
                                                        name.qualified-table.a
                                                        ==
                       fil
  ::
  =.  tmsp.tbl             sys-time
  =.  provenance.tbl       sap.bowl
  =.  column-lookup.tbl    final-lookup
  =.  typ-addr-lookup.tbl  final-typ-addr
  =.  columns.tbl          rebuilt-cols
  =.  pri-indx.tbl         [%index %.y final-key]
  =.  outbound-fk-index.tbl
        ?:  !=(rename-columns.a ~)
          (rename-outbound-fk-index outbound-fk-index.tbl rename-columns.a)
        outbound-fk-index.tbl
  =.  tables.nxt-schema
        %+  %~  put  by  ?~  new-name.a  tables.nxt-schema
                         (remove-key tables.nxt-schema src-key)
            target-key
            tbl
  =.  tmsp.nxt-schema        sys-time
  =.  provenance.nxt-schema  sap.bowl
  ::
  =.  files.nxt-data
        %+  %~  put  by  ?~  new-name.a  files.nxt-data
                         (remove-key files.nxt-data src-key)
            target-key
            final-file
  =/  rename-work
        ?~  new-name.a
          [tables.nxt-schema files.nxt-data]
        %:  rewrite-table-rename-fks
              src-key
              target-key
              tbl
              tables.nxt-schema
              files.nxt-data
              ==
  =.  tables.nxt-schema  -.rename-work
  =.  files.nxt-data     +.rename-work
  =/  column-rename-work
        ?:  =(rename-columns.a ~)
          [tables.nxt-schema files.nxt-data]
        %:  rewrite-column-rename-fks
              src-key
              target-key
              old-outgoing-fks
              foreign-constraints.final-file
              rename-columns.a
              tables.nxt-schema
              files.nxt-data
              ==
  =.  tables.nxt-schema  -.column-rename-work
  =.  files.nxt-data     +.column-rename-work
  =/  drop-work
        ?~  drop-foreign-keys.a
          [tables.nxt-schema files.nxt-data]
        =/  drop=[(list @tas) qualified-table:ast]  u.drop-foreign-keys.a
        =/  source-key  target-key
        =/  ref=qualified-table:ast  +.drop
        =/  parent-key=[@tas @tas]  [namespace.ref name.ref]
        ?.  (~(has by files.nxt-data) parent-key)
          ~|("ALTER TABLE: foreign key to drop does not exist" !!)
        =/  child-table=table  (~(got by tables.nxt-schema) source-key)
        =/  parent-file=file   (~(got by files.nxt-data) parent-key)
        =/  removed
              (unregister-fk source-key -.drop parent-key child-table parent-file sys-time)
        :-  (~(put by tables.nxt-schema) source-key child.removed)
            (~(put by files.nxt-data) parent-key parent.removed)
  =.  tables.nxt-schema  -.drop-work
  =.  files.nxt-data     +.drop-work
  =/  fk-work
        =/  source-key  target-key
        =/  out-tables  tables.nxt-schema
        =/  out-files   files.nxt-data
        =/  fks=(list foreign-key:ast)  add-foreign-keys.a
        |-
        ?~  fks  [out-tables out-files]
        =/  fk=foreign-key:ast  i.fks
        =/  dummy  (validate-add-fk source-key namespaces.nxt-schema out-tables out-files fk)
        =/  parent-key=[@tas @tas]
              [namespace.reference-table.fk name.reference-table.fk]
        =/  child-table  (~(got by out-tables) source-key)
        =/  child-file   (~(got by out-files) source-key)
        =/  parent-file  (~(got by out-files) parent-key)
        =/  registered
              (register-fk fk child-table child-file parent-file sys-time)
        %=  $
          fks         t.fks
          out-tables  (~(put by out-tables) source-key child.registered)
          out-files   (~(put by out-files) parent-key parent.registered)
        ==
  =.  tables.nxt-schema  -.fk-work
  =.  files.nxt-data     +.fk-work
  =.  ship.nxt-data        src.bowl
  =.  provenance.nxt-data  sap.bowl
  =.  tmsp.nxt-data        sys-time
  =.  sys.db               (put:schema-key sys.db sys-time nxt-schema)
  =.  content.db           (put:data-key content.db sys-time nxt-data)
  =.  event-log.db  :-  :*  %sys-log-event
                            sys-time
                            sap.bowl
                            %alter-table
                            %table
                            database.qualified-table.a
                            `namespace.qualified-table.a
                            `name.qualified-table.a
                            ?~(new-name.a ~ `database.qualified-table.a)
                            ?~(new-name.a ~ `namespace.qualified-table.a)
                            ?~(new-name.a ~ `target-name)
                            (alter-table-message a)
                            ==
                        event-log.db
  =.  view-cache.db  (upd-view-caches state db sys-time ~ %alter-table)
  =.  state          (update-sys state sys-time)
  :^  :-  %results
          :~  [%action (crip "ALTER TABLE {<name.qualified-table.a>}")]
              [%server-time now.bowl]
              [%schema-time sys-time]
              ==
      (~(put by next-schemas) database.qualified-table.a sys-time)
      (~(put by next-data) database.qualified-table.a sys-time)
      (~(put by state) name.db db)
::
++  drop-tbl
  |=  $:  d=drop-table:ast
          next-schemas=(map @tas @da)
          next-data=(map @tas @da)
          ==
  ^-  [cmd-result:ast (map @tas @da) (map @tas @da) server]
  =/  db  ~|  "DROP TABLE: database ".
              "{<database.qualified-table.d>} does not exist"
             (~(got by state) database.qualified-table.d)
  =/  sys-time  (set-tmsp as-of.d now.bowl)
  =/  nxt-schema=schema
        ~|  "DROP TABLE: {<name.qualified-table.d>} ".
            "as-of schema time out of order"
          %:  get-next-schema  sys.db
                              next-schemas
                              sys-time
                              database.qualified-table.d
                              ==
  =/  nxt-data=data
        ~|  "DROP TABLE: {<name.qualified-table.d>} ".
            "as-of data time out of order"
          %:  get-next-data  content.db
                              next-data
                              sys-time
                              database.qualified-table.d
                              ==
  ::
  ?.  (~(has by namespaces.nxt-schema) namespace.qualified-table.d)
    ~|  "DROP TABLE: namespace ".
        "{<namespace.qualified-table.d>} does not exist"
        !!
  ::
  =/  tbl-key=[@tas @tas]  [namespace.qualified-table.d name.qualified-table.d]
  =/  dropped-tbl=table
    ~|  "DROP TABLE: {<name.qualified-table.d>} ".
        "does not exist in {<namespace.qualified-table.d>}"
    %-  ~(got by tables.nxt-schema)
        tbl-key
  ::
  =/  dropped-file=file
        ~|  "DROP TABLE: {<namespace.qualified-table.d>}".
            ".{<name.qualified-table.d>} does not exist"
        %-  ~(got by files.nxt-data)
        tbl-key
  ?:  ?&((gth rowcount.dropped-file 0) =(force.d %.n))
    ~|("DROP TABLE: {<name.qualified-table.d>} has data, use FORCE to DROP" !!)
  =/  dummy
        ?.  force.d
          (assert-drop-table-no-fks tbl-key dropped-tbl dropped-file)
        ~
  =/  cleaned=[(map [@tas @tas] table) (map [@tas @tas] file)]
        ?:  force.d
          %:  remove-drop-table-fks
                tbl-key
                dropped-tbl
                dropped-file
                tables.nxt-schema
                files.nxt-data
                ==
        [tables.nxt-schema files.nxt-data]
  =.  tables.nxt-schema      -.cleaned
  =.  files.nxt-data         +.cleaned
  =/  table-map
    %+  remove-key
        tables.nxt-schema
        tbl-key
  =.  tables.nxt-schema      table-map
  =.  tmsp.nxt-schema        sys-time
  =.  provenance.nxt-schema  sap.bowl
  ::
  =/  file-map
    %+  remove-key
        files.nxt-data
        tbl-key
  =.  files.nxt-data       file-map
  =.  ship.nxt-data        src.bowl
  =.  provenance.nxt-data  sap.bowl
  =.  tmsp.nxt-data        sys-time
  ::
  =.  sys.db        (put:schema-key sys.db sys-time nxt-schema)
  =.  content.db    (put:data-key content.db sys-time nxt-data)
  =.  event-log.db  :-  :*  %sys-log-event
                            sys-time
                            sap.bowl
                            %drop
                            %table
                            database.qualified-table.d
                            `namespace.qualified-table.d
                            `name.qualified-table.d
                            ~
                            ~
                            ~
                            ~
                            ==
                        event-log.db
  =.  view-cache.db  (upd-view-caches state db sys-time ~ %drop-table)
  =.  state          (update-sys state sys-time)
  ::
  :^  ?:  (gth rowcount.dropped-file 0)
        :-  %results
            :~  [%action (crip "DROP TABLE {<name.qualified-table.d>}")]
                [%server-time now.bowl]
                [%schema-time sys-time]
                [%data-time sys-time]
                [%vector-count rowcount.dropped-file]
                ==
      :-  %results
          :~  [%action (crip "DROP TABLE {<name.qualified-table.d>}")]
              [%server-time now.bowl]
              [%schema-time sys-time]
              ==
      (~(put by next-schemas) database.qualified-table.d sys-time)
      (~(put by next-data) database.qualified-table.d sys-time)
      (~(put by state) name.db db)
::
++  map-insert
  |*  [m=(map) key=* value=*]
  ^+  m
  ?:  (~(has by m) key)  ~|("duplicate key: {<key>}" !!)
  (~(put by m) key value)
::
++  remove-key
  |*  [m=(map) key=*]
  ^+  m
  ?:  (~(has by m) key)  (~(del by m) key)
  ~|("deletion key does not exist: {<key>}" !!)
::
++  assert-drop-table-no-fks
  |=  [tbl-key=[@tas @tas] dropped-tbl=table dropped-file=file]
  ^-  ~
  ?:  ?|  (fk-outbound-index-has-entries outbound-fk-index.dropped-tbl)
          !=(~ foreign-constraints.dropped-file)
      ==
    ~|("DROP TABLE: {<+.tbl-key>} used in FOREIGN KEY, use FORCE to DROP" !!)
  ~
::
++  fk-outbound-index-has-entries
  |=  idx=outbound-fk-index
  ^-  ?
  (gth ~(wyt by idx) 0)
::
++  remove-drop-table-fks
  |=  $:  tbl-key=[@tas @tas]
          dropped-tbl=table
          dropped-file=file
          tbls=(map [@tas @tas] table)
          fils=(map [@tas @tas] file)
          ==
  ^-  [(map [@tas @tas] table) (map [@tas @tas] file)]
  =/  clean-files=(map [@tas @tas] file)
        (remove-dropped-table-outgoing-fks tbl-key dropped-tbl fils)
  =/  clean-tables=(map [@tas @tas] table)
        (remove-dropped-table-incoming-fks tbl-key foreign-constraints.dropped-file tbls)
  [clean-tables clean-files]
::
++  remove-dropped-table-outgoing-fks
  |=  $:  tbl-key=[@tas @tas]
          dropped-tbl=table
          fils=(map [@tas @tas] file)
          ==
  ^-  (map [@tas @tas] file)
  =/  fks=(list outbound-fk-entry)
        (collect-outbound-fks outbound-fk-index.dropped-tbl)
  =/  cur-files=(map [@tas @tas] file)  fils
  |-
  ?~  fks  cur-files
  =/  parent-key=[@tas @tas]  reference-table.i.fks
  =/  parent-fil=file  (~(got by cur-files) parent-key)
  =.  foreign-constraints.parent-fil
        (remove-incoming-fk foreign-constraints.parent-fil tbl-key constrained-columns.i.fks)
  =.  cur-files  (~(put by cur-files) parent-key parent-fil)
  $(fks t.fks)
::
++  remove-dropped-table-incoming-fks
  |=  $:  tbl-key=[@tas @tas]
          constraints=(list foreign-constraint)
          tbls=(map [@tas @tas] table)
          ==
  ^-  (map [@tas @tas] table)
  =/  cur-tables=(map [@tas @tas] table)  tbls
  |-
  ?~  constraints  cur-tables
  =/  child-key=[@tas @tas]  constrained-table.i.constraints
  =/  child-tbl=table  (~(got by cur-tables) child-key)
  =.  outbound-fk-index.child-tbl
        (remove-outbound-fk outbound-fk-index.child-tbl constrained-columns.i.constraints tbl-key)
  =.  cur-tables  (~(put by cur-tables) child-key child-tbl)
  $(constraints t.constraints)
::
++  collect-outbound-fks
  |=  idx=outbound-fk-index
  ^-  (list outbound-fk-entry)
  =/  pairs=(list [@tas (list outbound-fk-entry)])  ~(tap by idx)
  =/  out=(list outbound-fk-entry)  ~
  |-
  ?~  pairs  (flop out)
  =.  out  (add-unique-outbound-entries +.i.pairs out)
  $(pairs t.pairs)
::
++  add-unique-outbound-entries
  |=  [entries=(list outbound-fk-entry) out=(list outbound-fk-entry)]
  ^-  (list outbound-fk-entry)
  |-
  ?~  entries  out
  %=  $
    entries  t.entries
    out      ?:  (outbound-entry-exists out i.entries)  out
              [i.entries out]
  ==
::
++  outbound-entry-exists
  |=  [entries=(list outbound-fk-entry) entry=outbound-fk-entry]
  ^-  ?
  ?~  entries  %.n
  ?:  ?&  =(reference-table.i.entries reference-table.entry)
          =(constrained-columns.i.entries constrained-columns.entry)
          =(reference-columns.i.entries reference-columns.entry)
          ==
    %.y
  $(entries t.entries)
::
++  rewrite-table-rename-fks
  |=  $:  old-key=[@tas @tas]
          new-key=[@tas @tas]
          renamed-tbl=table
          tbls=(map [@tas @tas] table)
          fils=(map [@tas @tas] file)
          ==
  ^-  [(map [@tas @tas] table) (map [@tas @tas] file)]
  =/  outgoing=(list outbound-fk-entry)
        (collect-outbound-fks outbound-fk-index.renamed-tbl)
  =/  clean-files=(map [@tas @tas] file)
        (rewrite-renamed-child-in-parent-files old-key new-key outgoing fils)
  =/  parent-file=file  (~(got by clean-files) new-key)
  =/  clean-tables=(map [@tas @tas] table)
        (rewrite-renamed-parent-in-child-tables old-key new-key foreign-constraints.parent-file tbls)
  [clean-tables clean-files]
::
++  rewrite-renamed-child-in-parent-files
  |=  $:  old-key=[@tas @tas]
          new-key=[@tas @tas]
          fks=(list outbound-fk-entry)
          fils=(map [@tas @tas] file)
          ==
  ^-  (map [@tas @tas] file)
  =/  cur-files=(map [@tas @tas] file)  fils
  |-
  ?~  fks  cur-files
  =/  parent-key=[@tas @tas]
        ?:  =(reference-table.i.fks old-key)
          new-key
        reference-table.i.fks
  =/  parent-fil=file  (~(got by cur-files) parent-key)
  =.  foreign-constraints.parent-fil
        %:  rewrite-incoming-child-key
              foreign-constraints.parent-fil
              old-key
              new-key
              constrained-columns.i.fks
              ==
  =.  cur-files  (~(put by cur-files) parent-key parent-fil)
  $(fks t.fks)
::
++  rewrite-renamed-parent-in-child-tables
  |=  $:  old-key=[@tas @tas]
          new-key=[@tas @tas]
          constraints=(list foreign-constraint)
          tbls=(map [@tas @tas] table)
          ==
  ^-  (map [@tas @tas] table)
  =/  cur-tables=(map [@tas @tas] table)  tbls
  |-
  ?~  constraints  cur-tables
  =/  child-key=[@tas @tas]  constrained-table.i.constraints
  =/  child-tbl=table  (~(got by cur-tables) child-key)
  =.  outbound-fk-index.child-tbl
        %:  rewrite-outbound-reference
              outbound-fk-index.child-tbl
              constrained-columns.i.constraints
              old-key
              new-key
              ==
  =.  cur-tables  (~(put by cur-tables) child-key child-tbl)
  $(constraints t.constraints)
::
++  rewrite-incoming-child-key
  |=  $:  constraints=(list foreign-constraint)
          old-key=[@tas @tas]
          new-key=[@tas @tas]
          source-cols=(list @tas)
          ==
  ^-  (list foreign-constraint)
  =/  out=(list foreign-constraint)  ~
  |-
  ?~  constraints  (flop out)
  =/  item=foreign-constraint  i.constraints
  =.  item
        ?:  ?&  =(constrained-table.item old-key)
                =(constrained-columns.item source-cols)
                ==
          item(constrained-table new-key)
        item
  %=  $
    constraints  t.constraints
    out          [item out]
  ==
::
++  rewrite-outbound-reference
  |=  $:  idx=outbound-fk-index
          source-cols=(list @tas)
          old-parent=[@tas @tas]
          new-parent=[@tas @tas]
          ==
  ^-  outbound-fk-index
  =/  cols=(list @tas)  source-cols
  |-
  ?~  cols  idx
  =/  entries=(list outbound-fk-entry)  (~(got by idx) i.cols)
  =/  rewritten=(list outbound-fk-entry)
        (rewrite-outbound-entry-list entries source-cols old-parent new-parent)
  %=  $
    cols  t.cols
    idx   (~(put by idx) i.cols rewritten)
  ==
::
++  rewrite-outbound-entry-list
  |=  $:  entries=(list outbound-fk-entry)
          source-cols=(list @tas)
          old-parent=[@tas @tas]
          new-parent=[@tas @tas]
          ==
  ^-  (list outbound-fk-entry)
  =/  out=(list outbound-fk-entry)  ~
  |-
  ?~  entries  (flop out)
  =/  entry=outbound-fk-entry  i.entries
  =.  entry
        ?:  ?&  =(reference-table.entry old-parent)
                =(constrained-columns.entry source-cols)
                ==
          entry(reference-table new-parent)
        entry
  %=  $
    entries  t.entries
    out      [entry out]
  ==
::
++  assert-fk-column-change-allowed
  |=  $:  tbl=table
          fil=file
          drop-cols=(list @tas)
          alter-cols=(list column:ast)
          ==
  ^-  ~
  =/  cols=(list @tas)  (weld drop-cols (turn alter-cols |=(c=column:ast name.c)))
  |-
  ?~  cols  ~
  ?:  (fk-column-protected tbl fil i.cols)
    ~|("ALTER TABLE: column {<i.cols>} is referenced by FOREIGN KEY" !!)
  $(cols t.cols)
::
++  fk-column-protected
  |=  [tbl=table fil=file col=@tas]
  ^-  ?
  ?|  (~(has by outbound-fk-index.tbl) col)
      ?&  !=(~ foreign-constraints.fil)
          (name-in-list col (key-names key.pri-indx.tbl))
          ==
      ==
::
++  name-in-list
  |=  [needle=@tas names=(list @tas)]
  ^-  ?
  ?~  names  %.n
  ?:  =(needle i.names)  %.y
  $(names t.names)
::
++  rename-names
  |=  [names=(list @tas) renames=(list [@tas @tas])]
  ^-  (list @tas)
  (turn names |=(name=@tas (renamed-name name renames)))
::
++  rename-outbound-fk-index
  |=  [idx=outbound-fk-index renames=(list [@tas @tas])]
  ^-  outbound-fk-index
  =/  fks=(list outbound-fk-entry)  (collect-outbound-fks idx)
  =/  out=outbound-fk-index  ~
  |-
  ?~  fks  out
  =/  entry=outbound-fk-entry
        i.fks(constrained-columns (rename-names constrained-columns.i.fks renames))
  %=  $
    fks  t.fks
    out  (add-outbound-fk out constrained-columns.entry entry)
  ==
::
++  rewrite-column-rename-fks
  |=  $:  old-key=[@tas @tas]
          new-key=[@tas @tas]
          old-outgoing=(list outbound-fk-entry)
          incoming=(list foreign-constraint)
          renames=(list [@tas @tas])
          tbls=(map [@tas @tas] table)
          fils=(map [@tas @tas] file)
          ==
  ^-  [(map [@tas @tas] table) (map [@tas @tas] file)]
  =/  clean-files=(map [@tas @tas] file)
        %:  rewrite-source-column-in-parent-files
              old-key
              new-key
              old-outgoing
              renames
              fils
              ==
  =/  clean-tables=(map [@tas @tas] table)
        %:  rewrite-reference-column-in-child-tables
              new-key
              incoming
              renames
              tbls
              ==
  [clean-tables clean-files]
::
++  rewrite-source-column-in-parent-files
  |=  $:  old-key=[@tas @tas]
          new-key=[@tas @tas]
          old-outgoing=(list outbound-fk-entry)
          renames=(list [@tas @tas])
          fils=(map [@tas @tas] file)
          ==
  ^-  (map [@tas @tas] file)
  =/  cur-files=(map [@tas @tas] file)  fils
  |-
  ?~  old-outgoing  cur-files
  =/  parent-key=[@tas @tas]
        ?:  =(reference-table.i.old-outgoing old-key)
          new-key
        reference-table.i.old-outgoing
  =/  parent-fil=file  (~(got by cur-files) parent-key)
  =.  foreign-constraints.parent-fil
        %:  rewrite-incoming-source-cols
              foreign-constraints.parent-fil
              new-key
              constrained-columns.i.old-outgoing
              (rename-names constrained-columns.i.old-outgoing renames)
              ==
  =.  cur-files  (~(put by cur-files) parent-key parent-fil)
  $(old-outgoing t.old-outgoing)
::
++  rewrite-reference-column-in-child-tables
  |=  $:  parent-key=[@tas @tas]
          incoming=(list foreign-constraint)
          renames=(list [@tas @tas])
          tbls=(map [@tas @tas] table)
          ==
  ^-  (map [@tas @tas] table)
  =/  cur-tables=(map [@tas @tas] table)  tbls
  |-
  ?~  incoming  cur-tables
  =/  child-key=[@tas @tas]  constrained-table.i.incoming
  =/  child-tbl=table  (~(got by cur-tables) child-key)
  =.  outbound-fk-index.child-tbl
        %:  rewrite-outbound-reference-columns
              outbound-fk-index.child-tbl
              constrained-columns.i.incoming
              parent-key
              renames
              ==
  =.  cur-tables  (~(put by cur-tables) child-key child-tbl)
  $(incoming t.incoming)
::
++  rewrite-incoming-source-cols
  |=  $:  constraints=(list foreign-constraint)
          child-key=[@tas @tas]
          old-cols=(list @tas)
          new-cols=(list @tas)
          ==
  ^-  (list foreign-constraint)
  =/  out=(list foreign-constraint)  ~
  |-
  ?~  constraints  (flop out)
  =/  item=foreign-constraint  i.constraints
  =.  item
        ?:  ?&  =(constrained-table.item child-key)
                =(constrained-columns.item old-cols)
                ==
          item(constrained-columns new-cols)
        item
  %=  $
    constraints  t.constraints
    out          [item out]
  ==
::
++  rewrite-outbound-reference-columns
  |=  $:  idx=outbound-fk-index
          source-cols=(list @tas)
          parent-key=[@tas @tas]
          renames=(list [@tas @tas])
          ==
  ^-  outbound-fk-index
  =/  cols=(list @tas)  source-cols
  |-
  ?~  cols  idx
  =/  entries=(list outbound-fk-entry)  (~(got by idx) i.cols)
  =/  rewritten=(list outbound-fk-entry)
        %:  rewrite-outbound-reference-column-list
              entries
              source-cols
              parent-key
              renames
              ==
  %=  $
    cols  t.cols
    idx   (~(put by idx) i.cols rewritten)
  ==
::
++  rewrite-outbound-reference-column-list
  |=  $:  entries=(list outbound-fk-entry)
          source-cols=(list @tas)
          parent-key=[@tas @tas]
          renames=(list [@tas @tas])
          ==
  ^-  (list outbound-fk-entry)
  =/  out=(list outbound-fk-entry)  ~
  |-
  ?~  entries  (flop out)
  =/  entry=outbound-fk-entry  i.entries
  =.  entry
        ?:  ?&  =(reference-table.entry parent-key)
                =(constrained-columns.entry source-cols)
                ==
          entry(reference-columns (rename-names reference-columns.entry renames))
        entry
  %=  $
    entries  t.entries
    out      [entry out]
  ==
::
++  validate-create-fk
  |=  $:  source-key=[@tas @tas]
          =namespaces
          tbls=(map [@tas @tas] table)
          fils=(map [@tas @tas] file)
          fk=foreign-key:ast
          ==
  ^-  ~
  ?:  !=(database.qualified-table.fk database.reference-table.fk)
    ~|("CREATE TABLE: foreign key references another database" !!)
  ?.  (~(has by namespaces) namespace.reference-table.fk)
    ~|  "CREATE TABLE: namespace {<namespace.reference-table.fk>} ".
        "referenced by FOREIGN KEY does not exist"
        !!
  =/  child-table=table  (~(got by tbls) source-key)
  =/  parent-key=[@tas @tas]
        [namespace.reference-table.fk name.reference-table.fk]
  ?.  (~(has by tbls) parent-key)
    ~|  "CREATE TABLE: table {<name.reference-table.fk>} referenced by ".
        "FOREIGN KEY does not exist"
        !!
  =/  parent-table=table  (~(got by tbls) parent-key)
  =/  parent-file=file    (~(got by fils) parent-key)
  =/  dummy  (assert-fk-source-cols column-lookup.child-table columns.fk)
  =/  dummy
        (assert-fk-reference-cols column-lookup.parent-table reference-columns.fk)
  =/  parent-pk=(list @tas)  (key-names key.pri-indx.parent-table)
  ?.  =(reference-columns.fk parent-pk)
    ~|("CREATE TABLE: foreign key reference columns do not match referenced PRIMARY KEY" !!)
  =/  dummy
        %:  assert-fk-aura-match
              column-lookup.child-table
              column-lookup.parent-table
              columns.fk
              reference-columns.fk
              ==
  ?:  (fk-canonical-exists foreign-constraints.parent-file source-key columns.fk)
    ~|("CREATE TABLE: foreign key already exists" !!)
  =/  candidate=fk-graph-edge
        %:  make-fk-graph-edge
              source-key
              parent-key
              referential-integrity.fk
              ==
  =/  graph=(list fk-graph-edge)
        (fk-graph-with-candidate fils candidate)
  ?:  (fk-graph-candidate-has-cascading-cycle graph candidate)
    ~|("CREATE TABLE: cascading foreign-key cycle not allowed" !!)
  ~
::
++  validate-add-fk
  |=  $:  source-key=[@tas @tas]
          =namespaces
          tbls=(map [@tas @tas] table)
          fils=(map [@tas @tas] file)
          fk=foreign-key:ast
          ==
  ^-  ~
  ?:  !=(database.qualified-table.fk database.reference-table.fk)
    ~|("ALTER TABLE: foreign key references another database" !!)
  ?.  (~(has by namespaces) namespace.reference-table.fk)
    ~|  "ALTER TABLE: namespace {<namespace.reference-table.fk>} ".
        "referenced by FOREIGN KEY does not exist"
        !!
  =/  child-table=table  (~(got by tbls) source-key)
  =/  child-file=file    (~(got by fils) source-key)
  =/  parent-key=[@tas @tas]
        [namespace.reference-table.fk name.reference-table.fk]
  ?.  (~(has by tbls) parent-key)
    ~|  "ALTER TABLE: table {<name.reference-table.fk>} referenced by ".
        "FOREIGN KEY does not exist"
        !!
  =/  parent-table=table  (~(got by tbls) parent-key)
  =/  parent-file=file    (~(got by fils) parent-key)
  =/  dummy  (assert-fk-source-cols column-lookup.child-table columns.fk)
  =/  dummy
        (assert-fk-reference-cols column-lookup.parent-table reference-columns.fk)
  =/  parent-pk=(list @tas)  (key-names key.pri-indx.parent-table)
  ?.  =(reference-columns.fk parent-pk)
    ~|("ALTER TABLE: foreign key reference columns do not match referenced PRIMARY KEY" !!)
  =/  dummy
        %:  assert-fk-aura-match
              column-lookup.child-table
              column-lookup.parent-table
              columns.fk
              reference-columns.fk
              ==
  ?:  (fk-canonical-exists foreign-constraints.parent-file source-key columns.fk)
    ~|("ALTER TABLE: foreign key already exists" !!)
  =/  candidate=fk-graph-edge
        %:  make-fk-graph-edge
              source-key
              parent-key
              referential-integrity.fk
              ==
  =/  graph=(list fk-graph-edge)
        (fk-graph-with-candidate fils candidate)
  ?:  (fk-graph-candidate-has-cascading-cycle graph candidate)
    ~|("ALTER TABLE: cascading foreign-key cycle not allowed" !!)
  (assert-fk-existing-rows child-file parent-table parent-file columns.fk)
::
++  register-fk
  |=  $:  fk=foreign-key:ast
          child-table=table
          child-file=file
          parent-file=file
          registered-time=@da
          ==
  ^-  [child=table parent=file]
  =/  child-key=[@tas @tas]
        [namespace.qualified-table.fk name.qualified-table.fk]
  =/  parent-key=[@tas @tas]
        [namespace.reference-table.fk name.reference-table.fk]
  =/  incoming=foreign-constraint
        %:  seed-constrained-values-from-rows
              :*  child-key
                  (fk-constraints referential-integrity.fk)
                  (key-names key.pri-indx.child-table)
                  columns.fk
                  *constrained-values
                  ==
              child-file
              columns.fk
              ==
  =.  foreign-constraints.parent-file
        [incoming foreign-constraints.parent-file]
  =.  tmsp.parent-file  registered-time
  =/  outbound=outbound-fk-entry
        :*  parent-key
            columns.fk
            reference-columns.fk
            ==
  =.  outbound-fk-index.child-table
        (add-outbound-fk outbound-fk-index.child-table columns.fk outbound)
  [child-table parent-file]
::
++  unregister-fk
  |=  $:  child-key=[@tas @tas]
          source-cols=(list @tas)
          parent-key=[@tas @tas]
          child-table=table
          parent-file=file
          unregistered-time=@da
          ==
  ^-  [child=table parent=file]
  ?.  (fk-canonical-exists foreign-constraints.parent-file child-key source-cols)
    ~|("ALTER TABLE: foreign key to drop does not exist" !!)
  =.  foreign-constraints.parent-file
        (remove-incoming-fk foreign-constraints.parent-file child-key source-cols)
  =.  tmsp.parent-file  unregistered-time
  =.  outbound-fk-index.child-table
        (remove-outbound-fk outbound-fk-index.child-table source-cols parent-key)
  [child-table parent-file]
::
++  fk-constraints
  |=  ri=(list referential-integrity-action:ast)
  ^-  constraints
  =/  on-delete=key-constraint  %restrict
  =/  on-update=key-constraint  %restrict
  |-
  ?~  ri  [%constraints on-delete on-update]
  ?-  i.ri
    %delete-cascade      $(ri t.ri, on-delete %cascade)
    %delete-set-default  $(ri t.ri, on-delete %set-default)
    %update-cascade      $(ri t.ri, on-update %cascade)
    %update-set-default  $(ri t.ri, on-update %set-default)
  ==
::
++  add-outbound-fk
  |=  $:  idx=outbound-fk-index
          source-cols=(list @tas)
          entry=outbound-fk-entry
          ==
  ^-  outbound-fk-index
  ?~  source-cols  idx
  =/  current=(unit (list outbound-fk-entry))
        (~(get by idx) i.source-cols)
  %=  $
    source-cols  t.source-cols
    idx          (~(put by idx) i.source-cols ?~(current ~[entry] [entry u.current]))
  ==
::
++  remove-incoming-fk
  |=  $:  constraints=(list foreign-constraint)
          child-key=[@tas @tas]
          source-cols=(list @tas)
          ==
  ^-  (list foreign-constraint)
  =/  out=(list foreign-constraint)  ~
  |-
  ?~  constraints  (flop out)
  ?:  ?&  =(constrained-table.i.constraints child-key)
          =(constrained-columns.i.constraints source-cols)
          ==
    $(constraints t.constraints)
  %=  $
    constraints  t.constraints
    out          [i.constraints out]
  ==
::
++  remove-outbound-fk
  |=  $:  idx=outbound-fk-index
          source-cols=(list @tas)
          parent-key=[@tas @tas]
          ==
  ^-  outbound-fk-index
  =/  cols=(list @tas)  source-cols
  |-
  ?~  cols  idx
  =/  entries=(list outbound-fk-entry)  (~(got by idx) i.cols)
  =/  kept=(list outbound-fk-entry)
        (remove-outbound-entry entries parent-key)
  %=  $
    cols  t.cols
    idx   ?:  =(kept ~)  (~(del by idx) i.cols)
          (~(put by idx) i.cols kept)
  ==
::
++  remove-outbound-entry
  |=  [entries=(list outbound-fk-entry) parent-key=[@tas @tas]]
  ^-  (list outbound-fk-entry)
  =/  out=(list outbound-fk-entry)  ~
  |-
  ?~  entries  (flop out)
  ?:  =(reference-table.i.entries parent-key)
    $(entries t.entries)
  %=  $
    entries  t.entries
    out      [i.entries out]
  ==
::
++  assert-fk-existing-rows
  |=  $:  child-file=file
          parent-table=table
          parent-file=file
          source-cols=(list @tas)
          ==
  ^-  ~
  =/  parent-primary-key  (pri-key key.pri-indx.parent-table)
  =/  rows=(list indexed-row)  indexed-rows.child-file
  |-
  ?~  rows  ~
  =/  parent-key=(list @)  (fk-row-values data.i.rows source-cols)
  ?.  (has:parent-primary-key pri-idx.parent-file parent-key)
    ~|("ALTER TABLE: FOREIGN KEY parent key not found" !!)
  $(rows t.rows)
::
++  fk-row-values
  |=  [row=(map @tas @) cols=(list @tas)]
  ^-  (list @)
  =/  values=(list @)  ~
  |-
  ?~  cols  (flop values)
  %=  $
    cols    t.cols
    values  [(~(got by row) i.cols) values]
  ==
::
++  assert-fk-source-cols
  |=  [lookup=column-lookup cols=(list @tas)]
  ^-  ~
  ?~  cols  ~
  ?.  (~(has by lookup) i.cols)
    ~|("CREATE TABLE: foreign key source column {<i.cols>} does not exist" !!)
  $(cols t.cols)
::
++  assert-fk-reference-cols
  |=  [lookup=column-lookup cols=(list @tas)]
  ^-  ~
  ?~  cols  ~
  ?.  (~(has by lookup) i.cols)
    ~|  "CREATE TABLE: column {<i.cols>} referenced by FOREIGN KEY ".
        "does not exist"
        !!
  $(cols t.cols)
::
++  assert-fk-aura-match
  |=  $:  child-lookup=column-lookup
          parent-lookup=column-lookup
          source-cols=(list @tas)
          reference-cols=(list @tas)
          ==
  ^-  ~
  ?~  source-cols
    ?~  reference-cols  ~
    ~|("CREATE TABLE: foreign key reference columns do not match referenced PRIMARY KEY" !!)
  ?~  reference-cols
    ~|("CREATE TABLE: foreign key reference columns do not match referenced PRIMARY KEY" !!)
  ?.  =(-:(~(got by child-lookup) i.source-cols) -:(~(got by parent-lookup) i.reference-cols))
    ~|  "CREATE TABLE: aura mis-match in FOREIGN KEY ".
        "{<i.source-cols>} {<i.reference-cols>}"
        !!
  $(source-cols t.source-cols, reference-cols t.reference-cols)
::
++  fk-canonical-exists
  |=  $:  constraints=(list foreign-constraint)
          child-key=[@tas @tas]
          source-cols=(list @tas)
          ==
  ^-  ?
  ?~  constraints  %.n
  ?:  ?&  =(constrained-table.i.constraints child-key)
          =(constrained-columns.i.constraints source-cols)
          ==
    %.y
  $(constraints t.constraints)
::
++  key-names
  |=  key=(list key-column)
  ^-  (list @tas)
  (turn key |=(k=key-column name.k))
::
++  mk-key-column
  |=  [=column-lookup pri-indx=(list ordered-column:ast)]
  ^-  (list key-column)
  =/  key  *(list key-column)
  |-
  ?~  pri-indx  (flop key)
  %=  $
    pri-indx  t.pri-indx
    key       :-  :^  %key-column
                      name.i.pri-indx
                      -:(~(got by column-lookup) name.i.pri-indx)
                      ascending.i.pri-indx
                  key
  ==
::
++  name-set
  |*  a=(set)
  ~+   :: keep, seems to make small difference
  ^-  (set @tas)
  ~|  "CREATE TABLE: error in column names {<a>}"
  (~(run in a) |=(b=* ?@(b !! ?@(+<.b +<.b !!))))
::
++  alter-file
  |=  $:  fil=file
          add-cols=(list column:ast)
          drop-cols=(list @tas)
          renames=(list [@tas @tas])
          key=(list key-column)
          table-name=@tas
          ==
  ^-  file
  =.  indexed-rows.fil
        %+  turn  indexed-rows.fil
        |=  row=indexed-row
        =/  dat=(map @tas @)  (alter-row data.row add-cols drop-cols renames)
        [%indexed-row (row-key dat key) dat]
  =/  primary-key  (pri-key key)
  =/  comparator   ~(order idx-comp `(list [@ta ?])`(reduce-key key))
  =.  pri-idx.fil
        %+  gas:primary-key  *((mop (list @) (map @tas @)) comparator)
          (turn indexed-rows.fil |=(r=indexed-row [key.r data.r]))
  ?.  =(~(wyt by pri-idx.fil) rowcount.fil)
    ~|  "ALTER TABLE: {<table-name>} PRIMARY KEY is not unique over ".
        "existing data"
        !!
  =.  indexed-rows.fil
        %+  turn  (tap:primary-key pri-idx.fil)
        |=  r=[(list @) (map @tas @)]
        [%indexed-row -.r +.r]
  fil
::
++  alter-row
  |=  $:  row=(map @tas @)
          add-cols=(list column:ast)
          drop-cols=(list @tas)
          renames=(list [@tas @tas])
          ==
  ^-  (map @tas @)
  =/  out=(map @tas @)  row
  =.  out  (add-row-columns out add-cols)
  =.  out  (drop-row-columns out drop-cols)
  (rename-row-columns out renames)
::
++  add-row-columns
  |=  [row=(map @tas @) cols=(list column:ast)]
  ^-  (map @tas @)
  ?~  cols  row
  $(cols t.cols, row (~(put by row) name.i.cols (default-column-value i.cols)))
::
++  drop-row-columns
  |=  [row=(map @tas @) cols=(list @tas)]
  ^-  (map @tas @)
  ?~  cols  row
  $(cols t.cols, row (~(del by row) i.cols))
::
++  rename-row-columns
  |=  [row=(map @tas @) renames=(list [@tas @tas])]
  ^-  (map @tas @)
  ?~  renames  row
  =/  val=@  (~(got by row) -.i.renames)
  %=  $
    renames  t.renames
    row      (~(put by (~(del by row) -.i.renames)) +.i.renames val)
  ==
::
++  default-column-value
  |=  col=column:ast
  ^-  @
  ?:  =(%da type.col)  *@da
  0
::
++  row-key
  |=  [row=(map @tas @) key=(list key-column)]
  ^-  (list @)
  (turn key |=(k=key-column (~(got by row) name.k)))
::
++  column-map
  |=  cols=(list column:ast)
  ^-  (map @tas column:ast)
  (malt (turn cols |=(c=column:ast [name.c c])))
::
++  apply-add-columns
  |=  $:  table-name=@tas
          cols=(list column:ast)
          cmap=(map @tas column:ast)
          adds=(list column:ast)
          ==
  ^-  [cols=(list column:ast) cmap=(map @tas column:ast)]
  ?~  adds  [cols cmap]
  ?:  (~(has by cmap) name.i.adds)
    ~|("ALTER TABLE: {<table-name>} column {<name.i.adds>} already exists" !!)
  %=  $
    cols  (weld cols ~[i.adds])
    cmap  (~(put by cmap) name.i.adds i.adds)
    adds  t.adds
  ==
::
++  apply-drop-columns
  |=  $:  table-name=@tas
          cols=(list column:ast)
          cmap=(map @tas column:ast)
          drops=(list @tas)
          ==
  ^-  [cols=(list column:ast) cmap=(map @tas column:ast)]
  ?~  drops  [cols cmap]
  ?.  (~(has by cmap) i.drops)
    ~|("ALTER TABLE: {<table-name>} column {<i.drops>} does not exist" !!)
  %=  $
    cols   (drop-column cols i.drops)
    cmap   (~(del by cmap) i.drops)
    drops  t.drops
  ==
::
++  apply-rename-columns
  |=  $:  table-name=@tas
          cols=(list column:ast)
          cmap=(map @tas column:ast)
          renames=(list [@tas @tas])
          ==
  ^-  [cols=(list column:ast) cmap=(map @tas column:ast)]
  ?~  renames  [cols cmap]
  ?.  (~(has by cmap) -.i.renames)
    ~|  "ALTER TABLE: {<table-name>} column {<-.i.renames>} does not exist"
        !!
  ?:  (~(has by cmap) +.i.renames)
    ~|  "ALTER TABLE: {<table-name>} column {<+.i.renames>} already exists"
        !!
  =/  old=column:ast  (~(got by cmap) -.i.renames)
  =/  new=column:ast  old(name +.i.renames)
  %=  $
    cols     (rename-column cols -.i.renames +.i.renames)
    cmap     (~(put by (~(del by cmap) -.i.renames)) +.i.renames new)
    renames  t.renames
  ==
::
++  apply-alter-columns
  |=  $:  table-name=@tas
          cols=(list column:ast)
          cmap=(map @tas column:ast)
          alters=(list column:ast)
          ==
  ^-  [cols=(list column:ast) cmap=(map @tas column:ast)]
  ?~  alters  [cols cmap]
  ?.  (~(has by cmap) name.i.alters)
    ~|  "ALTER TABLE: {<table-name>} column {<name.i.alters>} does not exist"
        !!
  =/  old=column:ast  (~(got by cmap) name.i.alters)
  =/  new=column:ast  old(type type.i.alters)
  %=  $
    cols    (alter-column cols name.i.alters type.i.alters)
    cmap    (~(put by cmap) name.i.alters new)
    alters  t.alters
  ==
::
++  drop-column
  |=  [cols=(list column:ast) col=@tas]
  ^-  (list column:ast)
  (skim cols |=(c=column:ast !=(name.c col)))
::
++  rename-column
  |=  [cols=(list column:ast) old=@tas new=@tas]
  ^-  (list column:ast)
  %+  turn  cols
  |=  c=column:ast
  ?:  =(name.c old)  c(name new)
  c
::
++  alter-column
  |=  [cols=(list column:ast) col=@tas typ=@ta]
  ^-  (list column:ast)
  %+  turn  cols
  |=  c=column:ast
  ?:  =(name.c col)  c(type typ)
  c
::
++  order-columns
  |=  $:  table-name=@tas
          cols=(map @tas column:ast)
          old-cols=(list column:ast)
          names=(list @tas)
          ==
  ^-  (list column:ast)
  =/  ordered  *(list column:ast)
  =/  ns       names
  |-
  ?~  ns
    =/  out  (flop ordered)
    ?.  =((lent out) ~(wyt by cols))
      ~|("ALTER TABLE: {<table-name>} COLUMNS does not include every column" !!)
    ?:  =(out old-cols)
      ~|  "ALTER TABLE: {<table-name>} COLUMNS does not alter existing ".
          "canonical order"
          !!
    out
  ?.  (~(has by cols) i.ns)
    ~|("ALTER TABLE: {<table-name>} column {<i.ns>} does not exist" !!)
  $(ns t.ns, ordered [(~(got by cols) i.ns) ordered])
::
++  col-names
  |=  cols=(list ordered-column:ast)
  ^-  (list @tas)
  (turn cols |=(c=ordered-column:ast name.c))
::
++  missing-names
  |=  [lookup=column-lookup names=(list @tas)]
  ^-  (list @tas)
  (skim names |=(n=@tas !(~(has by lookup) n)))
::
++  assert-key-columns
  |=  [lookup=column-lookup names=(list @tas)]
  ^-  ~
  =/  missing=(list @tas)  (missing-names lookup names)
  ?~  missing  ~
  ~|  "ALTER TABLE: key column not in column definitions ".
      "{<i.missing>}"
      !!
::
++  rename-ordered-columns
  |=  [cols=(list ordered-column:ast) renames=(list [@tas @tas])]
  ^-  (list ordered-column:ast)
  %+  turn  cols
  |=  c=ordered-column:ast
  c(name (renamed-name name.c renames))
::
++  renamed-name
  |=  [name=@tas renames=(list [@tas @tas])]
  ^-  @tas
  ?~  renames  name
  ?:  =(name -.i.renames)  +.i.renames
  $(renames t.renames)
::
++  update-column-lookup-types
  |=  [lookup=column-lookup alters=(list column:ast)]
  ^-  column-lookup
  =/  out=column-lookup  lookup
  |-
  ?~  alters  out
  =/  old=[aura @]  (~(got by out) name.i.alters)
  =.  out  (~(put by out) name.i.alters [type.i.alters +.old])
  $(alters t.alters)
::
++  update-typ-addr-types
  |=  [lookup=(map @tas typ-addr) alters=(list column:ast)]
  ^-  (map @tas typ-addr)
  =/  out=(map @tas typ-addr)  lookup
  |-
  ?~  alters  out
  =/  old=typ-addr  (~(got by out) name.i.alters)
  =.  out  (~(put by out) name.i.alters old(type type.i.alters))
  $(alters t.alters)
::
++  alter-table-message
  |=  a=alter-table:ast
  ^-  (unit @t)
  =/  clauses=(list @t)  ~
  =.  clauses  ?:  !=(columns.a ~)         ['COLUMNS' clauses]        clauses
  =.  clauses  ?:  !=(pri-indx.a ~)        ['PRIMARY KEY' clauses]    clauses
  =.  clauses  ?:  !=(add-columns.a ~)     ['ADD COLUMN' clauses]     clauses
  =.  clauses  ?:  !=(drop-columns.a ~)    ['DROP COLUMN' clauses]    clauses
  =.  clauses  ?:  !=(rename-columns.a ~)  ['RENAME COLUMN' clauses]  clauses
  =.  clauses  ?:  !=(alter-columns.a ~)   ['ALTER COLUMN' clauses]   clauses
  =.  clauses  ?:  !=(add-foreign-keys.a ~)  ['ADD FOREIGN KEY' clauses]  clauses
  =.  clauses  ?:  ?=(^ drop-foreign-keys.a)  ['DROP FOREIGN KEY' clauses]  clauses
  ?~  clauses  ~
  [~ (join-text (flop clauses) '; ')]
::
++  join-text
  |=  [items=(list @t) sep=@t]
  ^-  @t
  ?~  items  ''
  =/  out=tape  (trip i.items)
  =/  rest=(list @t)  t.items
  |-
  ?~  rest  (crip out)
  =.  out  (weld out (weld (trip sep) (trip i.rest)))
  $(rest t.rest)
::
++  assert-no-dups
  |=  [msg=tape names=(list @tas)]
  ^-  ~
  =/  seen=(set @tas)  *(set @tas)
  |-
  ?~  names  ~
  ?:  (~(has in seen) i.names)
    ~|((weld msg (weld " %" (trip `@t`i.names))) !!)
  $(names t.names, seen (~(put in seen) i.names))
--
