/-  ast, *obelisk
/+  *utils
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
::
::  +create-ns:
::    [create-namespace:ast (map @tas @da) (map @tas @da)]
::    -> [cmd-result (map @tas @da) server]
++  create-ns
  |=  $:  =create-namespace:ast
          next-schemas=(map @tas @da)
          next-data=(map @tas @da)
      ==
  ^-  [cmd-result (map @tas @da) server]
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
          :~  [%message (crip "CREATE NAMESPACE {<name.create-namespace>}")]
              [%server-time now.bowl]
              [%schema-time sys-time]
              ==
      (~(put by next-schemas) database-name.create-namespace sys-time)
      (~(put by state) name.db db)
::
::  +create-tbl:
::    [create-table:ast (map @tas @da) (map @tas @da)]
::    -> [cmd-result (map @tas @da) (map @tas @da) server]
++  create-tbl
  |=  $:  =create-table:ast
          next-schemas=(map @tas @da)
          next-data=(map @tas @da)
          ==
  ^-  [cmd-result (map @tas @da) (map @tas @da) server]
  =/  db  ~|  "CREATE TABLE: database {<database.table.create-table>} ".
              "does not exist"
              (~(got by state) database.table.create-table)
  =/  sys-time  (set-tmsp as-of.create-table now.bowl)
  =/  nxt-schema=schema
        ~|  "CREATE TABLE: {<name.table.create-table>} as-of schema ".
            "time out of order"
            %:  get-next-schema  sys.db
                                 next-schemas
                                 sys-time
                                 database.table.create-table
                                 ==
  =/  nxt-data=data
        ~|  "CREATE TABLE: {<name.table.create-table>} as-of data ".
            "time out of order"
            %:  get-next-data  content.db
                               next-data
                               sys-time
                               database.table.create-table
                               ==
  ::
  ?.  (~(has by namespaces.nxt-schema) namespace.table.create-table)
    ~|  "CREATE TABLE: namespace {<namespace.table.create-table>} ".
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
  =/  column-look-up  (malt (spun columns.create-table make-col-lu-data))
  ::
  =/  table
        %:  table
            %table
            sap.bowl
            sys-time
            column-look-up
            %:  index
                %index
                %.y
                (mk-key-column column-look-up pri-indx.create-table)
            ==
            columns.create-table
            ~
        ==
  =/  tables
    ~|  "CREATE TABLE: {<name.table.create-table>} ".
        "exists in {<namespace.table.create-table>}"
    %:  map-insert
        tables.nxt-schema
        [namespace.table.create-table name.table.create-table]
        table
    ==
  =.  tables.nxt-schema      tables
  =.  tmsp.nxt-schema        sys-time
  =.  provenance.nxt-schema  sap.bowl
  ::
  =/  file  %:  file
                %file
                src.bowl
                sap.bowl
                sys-time
                0
                ~
                ~
                ~
                ~
            ==
  =/  files
    ~|  "CREATE TABLE: {<name.table.create-table>} ".
        "exists in {<namespace.table.create-table>}"
    %:  map-insert
        files.nxt-data
        [namespace.table.create-table name.table.create-table]
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
          :~  [%message (crip "CREATE TABLE {<name.table.create-table>}")]
              [%server-time now.bowl]
              [%schema-time sys-time]
              ==
      (~(put by next-schemas) database.table.create-table sys-time)
      (~(put by next-data) database.table.create-table sys-time)
      (~(put by state) name.db db)
::
::  +drop-tbl:
::    [drop-table:ast (map @tas @da) (map @tas @da)] -> table-return
++  drop-tbl
  |=  $:  d=drop-table:ast
          next-schemas=(map @tas @da)
          next-data=(map @tas @da)
          ==
  ^-  [cmd-result (map @tas @da) (map @tas @da) server]
  =/  db  ~|  "DROP TABLE: database {<database.table.d>} does not exist"
             (~(got by state) database.table.d)
  =/  sys-time  (set-tmsp as-of.d now.bowl)
  =/  nxt-schema=schema
        ~|  "DROP TABLE: {<name.table.d>} as-of schema time out of order"
          %:  get-next-schema  sys.db
                              next-schemas
                              sys-time
                              database.table.d
                              ==
  =/  nxt-data=data
        ~|  "DROP TABLE: {<name.table.d>} as-of data time out of order"
          %:  get-next-data  content.db
                              next-data
                              sys-time
                              database.table.d
                              ==
  ::
  ?.  (~(has by namespaces.nxt-schema) namespace.table.d)
    ~|("DROP TABLE: namespace {<namespace.table.d>} does not exist" !!)
  ::
  =/  tables
    ~|  "DROP TABLE: {<name.table.d>} does not exist in {<namespace.table.d>}"
    %+  map-delete
        tables.nxt-schema
        [namespace.table.d name.table.d]
  =.  tables.nxt-schema      tables
  =.  tmsp.nxt-schema        sys-time
  =.  provenance.nxt-schema  sap.bowl
  ::
  =/  file
        ~|  "DROP TABLE: {<namespace.table.d>}.{<name.table.d>} does not exist"
            (~(got by files.nxt-data) [namespace.table.d name.table.d])
  ?:  ?&((gth rowcount.file 0) =(force.d %.n))
    ~|("DROP TABLE: {<name.table.d>} has data, use FORCE to DROP" !!)
  =/  files
    %+  map-delete
        files.nxt-data
        [namespace.table.d name.table.d]
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
            :~  [%message (crip "DROP TABLE {<name.table.d>}")]
                [%server-time now.bowl]
                [%schema-time sys-time]
                [%data-time sys-time]
                [%vector-count rowcount.file]
                ==
      :-  %results
          :~  [%message (crip "DROP TABLE {<name.table.d>}")]
              [%server-time now.bowl]
              [%schema-time sys-time]
              ==
      (~(put by next-schemas) database.table.d sys-time)
      (~(put by next-data) database.table.d sys-time)
      (~(put by state) name.db db)
--