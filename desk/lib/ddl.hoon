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
  =/  tables
    ~|  "DROP TABLE: {<name.qualified-table.d>} ".
        "does not exist in {<namespace.qualified-table.d>}"
    %+  map-delete
        tables.nxt-schema
        [namespace.qualified-table.d name.qualified-table.d]
  =.  tables.nxt-schema      tables
  =.  tmsp.nxt-schema        sys-time
  =.  provenance.nxt-schema  sap.bowl
  ::
  =/  file
        ~|  "DROP TABLE: {<namespace.qualified-table.d>}".
            ".{<name.qualified-table.d>} does not exist"
        %-  ~(got by files.nxt-data)
        [namespace.qualified-table.d name.qualified-table.d]
  ?:  ?&((gth rowcount.file 0) =(force.d %.n))
    ~|("DROP TABLE: {<name.qualified-table.d>} has data, use FORCE to DROP" !!)
  =/  files
    %+  map-delete
        files.nxt-data
        [namespace.qualified-table.d name.qualified-table.d]
  =.  files.nxt-data       files
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
  :^  ?:  (gth rowcount.file 0)
        :-  %results
            :~  [%action (crip "DROP TABLE {<name.qualified-table.d>}")]
                [%server-time now.bowl]
                [%schema-time sys-time]
                [%data-time sys-time]
                [%vector-count rowcount.file]
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
++  map-delete
  |*  [m=(map) key=*]
  ^+  m
  ?:  (~(has by m) key)  (~(del by m) key)
  ~|("deletion key does not exist: {<key>}" !!)
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
--
