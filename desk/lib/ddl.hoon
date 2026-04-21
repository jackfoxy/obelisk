/-  ast, *obelisk, *server-state-0
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
  =.  sys.db         (put:schema-key sys.db sys-time nxt-schema)
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
  =.  sys.db         (put:schema-key sys.db sys-time nxt-schema)
  =.  content.db     (put:data-key content.db sys-time nxt-data)
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
  =.  sys.db         (put:schema-key sys.db sys-time nxt-schema)
  =.  content.db     (put:data-key content.db sys-time nxt-data)
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