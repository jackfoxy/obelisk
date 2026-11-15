/-  ast=obelisk-ast
/+  parse,  *test, *test-helpers
::
:: INSERT and UPSERT parse tests.
::
|%

::
:: insert
::
:: tests 1, 2, 3, 5, and extra whitespace characters, db.ns.table, db..table, colum list, two value rows, one value row, no space around ; delimeter
:: NOTE: the parser does not check:
::       1) validity of columns re parent table
::       2) match column count to values count
::       3) enforce consistent value counts across rows
++  test-insert-00
  =/  expected1
    :+  %crud-txn
        ctes=~
        :-  %insert
            :*  %insert
                :*  %qualified-table
                    ship=~
                    database='db'
                    namespace='ns'
                    name='my-table'
                    alias=~
                    ==
                as-of=~
                :-  ~
                    :~  'col1'
                        'col2'
                        'col3'
                        'col4'
                        'col5'
                        'col6'
                        'col7'
                        'col8'
                        'col9'
                        ==
                :-  %data
                    :~  :~  [~.t 1.685.221.219]
                            [~.rs 1.078.523.331]
                            [~.sd 39]
                            [~.ud 20]
                            [~.rs 1.078.523.331]
                            [~.p 28.242.037]
                            [~.rs 3.226.006.979]
                            [~.t 430.158.540.643]
                            [~.sd 6]
                            ==
                        :~  %default
                            [~.if 3.284.569.946]
                            [~.ud 195.198.143.900]
                            ==
                        ==
            ==
  =/  expected2
    :+  %crud-txn
        ctes=~
        :-  %insert
            :*  %insert
                :*  %qualified-table
                    ship=~
                    database='db'
                    namespace='dbo'
                    name='my-table'
                    alias=~
                    ==
                as-of=~
                :-  ~
                    :~  'col1'
                        'col2'
                        'col3'
                        'col4'
                        'col5'
                        'col6'
                        'col7'
                        'col8'
                        'col9'
                        ==
                :-  %data
                    :~  :~  [~.t 1.685.221.219]
                            [~.rs 1.078.523.331]
                            [~.sd 39]
                            [~.ud 20]
                            [~.rs 1.078.523.331]
                            [~.p 28.242.037]
                            [~.rs 3.226.006.979]
                            [~.t 430.158.540.643]
                            [~.sd 6]
                            ==
                        ==
            ==
  =/  urql1  " iNsert  iNto  db.ns.my-table  ".
    "( col1 ,  col2 ,  col3 ,  col4 ,  col5 ,  col6 ,  col7 ,  col8 ,  col9 )".
    " Values  ".
    "('cord',.3.14,-20,20,.3.14,~nomryg-nilref,.-3.14, 'cor\\'d', --3)".
    "  (Default,.195.198.143.90, 195.198.143.900)"
  =/  urql2  "insert into db..my-table ".
    "(col1, col2, col3, col4, col5, col6, col7, col8, col9)".
    "valueS ('cord',.3.14,-20,20,.3.14,~nomryg-nilref,.-3.14, 'cor\\'d', --3)"
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  (parse:parse(default-database 'other-db') (weld urql1 (weld ";" urql2)))
::
:: no columns, 3 rows
++  test-insert-01
  =/  expected
    :+  %crud-txn
        ctes=~
        :-  %insert
            :*  %insert
                :*  %qualified-table
                    ship=~
                    database='db1'
                    namespace='dbo'
                    name='my-table'
                    alias=~
                    ==
                as-of=~
                columns=~
                :-  %data
                    :~  :~  [~.t 1.685.221.219]
                            [~.rs 1.078.523.331]
                            [~.sd 39]
                            [~.ud 20]
                            [~.rs 1.078.523.331]
                            [~.p 28.242.037]
                            [~.rs 3.226.006.979]
                            [~.t 430.158.540.643]
                            [~.sd 6]
                            ==
                        :~  %default
                            [~.if 3.284.569.946]
                            [~.ud 195.198.143.900]
                            ==
                        :~  [~.ud 2.222]
                            [~.ud 2.222]
                            [~.ud 195.198.143.900]
                            [~.rs 1.078.523.331]
                            [~.rs 3.226.006.979]
                            [~.rd 4.614.253.070.214.989.087]
                            [~.rd 13.837.625.107.069.764.895]
                            [~.ux 1.205.249]
                            [~.ub 43]
                            [~.sd 39]
                            [~.sd 40]
                            [~.uw 61.764.130.813.526]
                            [~.uw 1.870.418.170.505.042.572.886]
                            ==
                        ==
            ==
  =/  urql  "insert into my-table ".
    "values ('cord',.3.14,-20,20,.3.14,~nomryg-nilref,.-3.14, 'cor\\'d', --3)".
    " (default,.195.198.143.90, 195.198.143.900)".
    " (2.222,2222,195.198.143.900,.3.14,.-3.14,.~3.14,.~-3.14,0x12.6401,10.1011,".
    "-20,--20,e2O.l4Xpm,pm.l4e2O.l4Xpm)"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)
::
:: no columns, 3 rows, as of now
++  test-insert-02
  =/  expected
    :+  %crud-txn
        ctes=~
        :-  %insert
            :*  %insert
                :*  %qualified-table
                    ship=~
                    database='db1'
                    namespace='dbo'
                    name='my-table'
                    alias=~
                    ==
                as-of=~
                columns=~
                :-  %data
                    :~  :~  [~.t 1.685.221.219]
                            [~.rs 1.078.523.331]
                            [~.sd 39]
                            [~.ud 20]
                            [~.rs 1.078.523.331]
                            [~.p 28.242.037]
                            [~.rs 3.226.006.979]
                            [~.t 430.158.540.643]
                            [~.sd 6]
                            ==
                        :~  %default
                            [~.if 3.284.569.946]
                            [~.ud 195.198.143.900]
                            ==
                        :~  [~.ud 2.222]
                            [~.ud 2.222]
                            [~.ud 195.198.143.900]
                            [~.rs 1.078.523.331]
                            [~.rs 3.226.006.979]
                            [~.rd 4.614.253.070.214.989.087]
                            [~.rd 13.837.625.107.069.764.895]
                            [~.ux 1.205.249]
                            [~.ub 43]
                            [~.sd 39]
                            [~.sd 40]
                            [~.uw 61.764.130.813.526]
                            [~.uw 1.870.418.170.505.042.572.886]
                            ==
                        ==
            ==
  =/  urql  "insert into my-table as of now ".
    "values ('cord',.3.14,-20,20,.3.14,~nomryg-nilref,.-3.14, 'cor\\'d', --3)".
    " (default,.195.198.143.90, 195.198.143.900)".
    " (2.222,2222,195.198.143.900,.3.14,.-3.14,.~3.14,.~-3.14,0x12.6401,10.1011,".
    "-20,--20,e2O.l4Xpm,pm.l4e2O.l4Xpm)"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)
::
:: no columns, 3 rows, as of ~2023.12.25..7.15.0..1ef5
++  test-insert-03
  =/  expected
    :+  %crud-txn
        ctes=~
        :-  %insert
            :*  %insert
                :*  %qualified-table
                    ship=~
                    database='db1'
                    namespace='dbo'
                    name='my-table'
                    alias=~
                    ==
                as-of=[~ [%da ~2023.12.25..7.15.0..1ef5]]
                columns=~
                :-  %data
                    :~  :~  [~.t 1.685.221.219]
                            [~.rs 1.078.523.331]
                            [~.sd 39]
                            [~.ud 20]
                            [~.rs 1.078.523.331]
                            [~.p 28.242.037]
                            [~.rs 3.226.006.979]
                            [~.t 430.158.540.643]
                            [~.sd 6]
                            ==
                        :~  %default
                            [~.if 3.284.569.946]
                            [~.ud 195.198.143.900]
                            ==
                        :~  [~.ud 2.222]
                            [~.ud 2.222]
                            [~.ud 195.198.143.900]
                            [~.rs 1.078.523.331]
                            [~.rs 3.226.006.979]
                            [~.rd 4.614.253.070.214.989.087]
                            [~.rd 13.837.625.107.069.764.895]
                            [~.ux 1.205.249]
                            [~.ub 43]
                            [~.sd 39]
                            [~.sd 40]
                            [~.uw 61.764.130.813.526]
                            [~.uw 1.870.418.170.505.042.572.886]
                            ==
                        ==
            ==
  =/  urql  "insert into my-table as of ~2023.12.25..7.15.0..1ef5".
    "values ('cord',.3.14,-20,20,.3.14,~nomryg-nilref,.-3.14, 'cor\\'d', --3)".
    " (default,.195.198.143.90, 195.198.143.900)".
    " (2.222,2222,195.198.143.900,.3.14,.-3.14,.~3.14,.~-3.14,0x12.6401,10.1011,".
    "-20,--20,e2O.l4Xpm,pm.l4e2O.l4Xpm)"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)
::
:: no columns, 3 rows, as of 5 days ago
++  test-insert-04
  =/  expected
    :+  %crud-txn
        ctes=~
        :-  %insert
            :*  %insert
                :*  %qualified-table
                    ship=~
                    database='db1'
                    namespace='dbo'
                    name='my-table'
                    alias=~
                    ==
                as-of=[~ %as-of-offset 5 %days]
                columns=~
                :-  %data
                    :~  :~  [~.t 1.685.221.219]
                            [~.rs 1.078.523.331]
                            [~.sd 39]
                            [~.ud 20]
                            [~.rs 1.078.523.331]
                            [~.p 28.242.037]
                            [~.rs 3.226.006.979]
                            [~.t 430.158.540.643]
                            [~.sd 6]
                            ==
                        :~  %default
                            [~.if 3.284.569.946]
                            [~.ud 195.198.143.900]
                            ==
                        :~  [~.ud 2.222]
                            [~.ud 2.222]
                            [~.ud 195.198.143.900]
                            [~.rs 1.078.523.331]
                            [~.rs 3.226.006.979]
                            [~.rd 4.614.253.070.214.989.087]
                            [~.rd 13.837.625.107.069.764.895]
                            [~.ux 1.205.249]
                            [~.ub 43]
                            [~.sd 39]
                            [~.sd 40]
                            [~.uw 61.764.130.813.526]
                            [~.uw 1.870.418.170.505.042.572.886]
                            ==
                        ==
            ==
  =/  urql  "insert into my-table  as of 5 days ago".
    "values ('cord',.3.14,-20,20,.3.14,~nomryg-nilref,.-3.14, 'cor\\'d', --3)".
    " (default,.195.198.143.90, 195.198.143.900)".
    " (2.222,2222,195.198.143.900,.3.14,.-3.14,.~3.14,.~-3.14,0x12.6401,10.1011,".
    "-20,--20,e2O.l4Xpm,pm.l4e2O.l4Xpm)"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)
::
:: no columns, 3 rows, as of now
++  test-insert-05
  =/  expected
    :+  %crud-txn
        ctes=~
        :-  %insert
            :*  %insert
                :*  %qualified-table
                    ship=~
                    database='db'
                    namespace='ns'
                    name='my-table'
                    alias=~
                    ==
                as-of=~
                :-  ~
                    :~  'col1'
                        'col2'
                        'col3'
                        'col4'
                        'col5'
                        'col6'
                        'col7'
                        'col8'
                        'col9'
                        ==
                :-  %data
                    :~  :~  [~.t 1.685.221.219]
                            [~.rs 1.078.523.331]
                            [~.sd 39]
                            [~.ud 20]
                            [~.rs 1.078.523.331]
                            [~.p 28.242.037]
                            [~.rs 3.226.006.979]
                            [~.t 430.158.540.643]
                            [~.sd 6]
                            ==
                        :~  %default
                            [~.if 3.284.569.946]
                            [~.ud 195.198.143.900]
                            ==
                        ==
            ==
  =/  urql  "insert  into  db.ns.my-table as of now ".
    "(col1, col2, col3, col4, col5, col6, col7, col8, col9 )".
    " values  ".
    "  ('cord',.3.14,-20,20,.3.14,~nomryg-nilref,.-3.14, 'cor\\'d', --3)".
    "  (default,.195.198.143.90, 195.198.143.900)"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'other-db') urql)
::
:: no columns, 3 rows, as of now
++  test-insert-06
  =/  expected
    :+  %crud-txn
        ctes=~
        :-  %insert
            :*  %insert
                :*  %qualified-table
                    ship=~
                    database='db'
                    namespace='ns'
                    name='my-table'
                    alias=~
                    ==
                as-of=[~ [%da ~2023.12.25..7.15.0..1ef5]]
                :-  ~
                    :~  'col1'
                        'col2'
                        'col3'
                        'col4'
                        'col5'
                        'col6'
                        'col7'
                        'col8'
                        'col9'
                        ==
                :-  %data
                    :~  :~  [~.t 1.685.221.219]
                            [~.rs 1.078.523.331]
                            [~.sd 39]
                            [~.ud 20]
                            [~.rs 1.078.523.331]
                            [~.p 28.242.037]
                            [~.rs 3.226.006.979]
                            [~.t 430.158.540.643]
                            [~.sd 6]
                            ==
                        :~  %default
                            [~.if 3.284.569.946]
                            [~.ud 195.198.143.900]
                            ==
                        ==
            ==
  =/  urql  "insert  into  db.ns.my-table  as of ~2023.12.25..7.15.0..1ef5".
    "(col1, col2, col3, col4, col5, col6, col7, col8, col9 )".
    " values ".
    " ('cord',.3.14,-20,20,.3.14,~nomryg-nilref,.-3.14, 'cor\\'d', --3)".
    "  (default,.195.198.143.90, 195.198.143.900)"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'other-db') urql)
::
:: no columns, 3 rows, as of offset
++  test-insert-07
  =/  expected
    :+  %crud-txn
        ctes=~
        :-  %insert
            :*  %insert
                :*  %qualified-table
                    ship=~
                    database='db'
                    namespace='ns'
                    name='my-table'
                    alias=~
                    ==
                as-of=[~ %as-of-offset 5 %days]
                :-  ~
                    :~  'col1'
                        'col2'
                        'col3'
                        'col4'
                        'col5'
                        'col6'
                        'col7'
                        'col8'
                        'col9'
                        ==
                :-  %data
                    :~  :~  [~.t 1.685.221.219]
                            [~.rs 1.078.523.331]
                            [~.sd 39]
                            [~.ud 20]
                            [~.rs 1.078.523.331]
                            [~.p 28.242.037]
                            [~.rs 3.226.006.979]
                            [~.t 430.158.540.643]
                            [~.sd 6]
                            ==
                        :~  %default
                            [~.if 3.284.569.946]
                            [~.ud 195.198.143.900]
                            ==
                        ==
            ==
  =/  urql  "insert  into  db.ns.my-table as of 5 days ago ".
    "(col1, col2, col3, col4, col5, col6, col7, col8, col9 )".
    " values ".
    " ('cord',.3.14,-20,20,.3.14,~nomryg-nilref,.-3.14, 'cor\\'d', --3)".
    "  (default,.195.198.143.90, 195.198.143.900)"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'other-db') urql)
::
:: every column type, no spaces around values
++  test-insert-08
  =/  row1
    :~  [~.t 1.685.221.219]
        [~.p 28.242.037]
        [~.p 28.242.037]
        [~.da 170.141.184.504.830.774.788.415.618.594.688.204.800]
        [~.da 170.141.184.504.830.774.788.415.618.594.688.204.800]
        [~.dr 114.450.695.119.985.999.668.576.256]
        [~.dr 114.450.695.119.985.999.668.576.256]
        [~.if 3.284.569.946]
        [~.is 123.543.654.234]
        [~.f 0]
        [~.f 1]
        [~.f 0]
        [~.f 1]
        [~.ud 2.222]
        [~.ud 2.222]
        [~.ud 195.198.143.900]
        [~.rs 1.078.523.331]
        [~.rs 3.226.006.979]
        [~.rd 4.614.253.070.214.989.087]
        [~.rd 13.837.625.107.069.764.895]
        [~.ux 1.205.249]
        [~.ub 43]
        [~.sd 39]
        [~.sd 40]
        [~.uw 61.764.130.813.526]
        [~.uw 1.870.418.170.505.042.572.886]
        ==
  =/  expected
    :+  %crud-txn
        ctes=~
        :-  %insert
            :*  %insert
                :*  %qualified-table
                    ship=~
                    database='db'
                    namespace='ns'
                    name='my-table'
                    alias=~
                    ==
                as-of=~
                columns=~
                [%data ~[row1]]
                ==
  =/  urql  "insert into db.ns.my-table ".
    "values ('cord',~nomryg-nilref,nomryg-nilref,~2020.12.25..7.15.0..1ef5,".
    "2020.12.25..7.15.0..1ef5,~d71.h19.m26.s24..9d55, d71.h19.m26.s24..9d55,".
    ".195.198.143.90,.0.0.0.0.0.1c.c3c6.8f5a,y,n,Y,N,".
    "2.222,2222,195.198.143.900,.3.14,.-3.14,.~3.14,.~-3.14,0x12.6401,10.1011,".
    "-20,--20,e2O.l4Xpm,pm.l4e2O.l4Xpm)"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)
::
:: every column type, spaces on all sides of values, comma inside cord
++  test-insert-09
  =/  row1
    :~  [~.t 430.242.426.723]
        [~.p 28.242.037]
        [~.p 28.242.037]
        [~.da 170.141.184.504.830.774.788.415.618.594.688.204.800]
        [~.da 170.141.184.504.830.774.788.415.618.594.688.204.800]
        [~.dr 114.450.695.119.985.999.668.576.256]
        [~.dr 114.450.695.119.985.999.668.576.256]
        [~.if 3.284.569.946]
        [~.is 123.543.654.234]
        [~.f 0]
        [~.f 1]
        [~.f 0]
        [~.f 1]
        [~.ud 2.222]
        [~.ud 2.222]
        [~.ud 195.198.143.900]
        [~.rs 1.078.523.331]
        [~.rs 3.226.006.979]
        [~.rd 4.614.253.070.214.989.087]
        [~.rd 13.837.625.107.069.764.895]
        [~.ux 1.205.249]
        [~.ub 43]
        [~.sd 39]
        [~.sd 40]
        [~.uw 61.764.130.813.526]
        [~.uw 1.870.418.170.505.042.572.886]
        ==
  =/  expected
    :+  %crud-txn
        ctes=~
        :-  %insert
            :*  %insert
                :*  %qualified-table
                    ship=~
                    database='db'
                    namespace='ns'
                    name='my-table'
                    alias=~
                    ==
                as-of=~
                columns=~
                [%data ~[row1]]
                ==
  =/  urql  "insert into db.ns.my-table ".
    "values ( 'cor,d' , ~nomryg-nilref , nomryg-nilref , ".
    "~2020.12.25..7.15.0..1ef5 , 2020.12.25..7.15.0..1ef5 , ".
    "~d71.h19.m26.s24..9d55 ,  d71.h19.m26.s24..9d55 , .195.198.143.90 , ".
    ".0.0.0.0.0.1c.c3c6.8f5a , y , n , Y , N , 2.222 , 2222 , ".
    "195.198.143.900 , .3.14 , .-3.14 , .~3.14 , .~-3.14 , 0x12.6401 , 10.1011 ,".
    " -20 , --20 , e2O.l4Xpm , pm.l4e2O.l4Xpm )"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)
::
:: every numeric type, no spaces around values
++  test-insert-10
  =/  expected
    :~
      :+  %crud-txn
          ctes=~
          :-  %insert
              :*  %insert
                  :*  %qualified-table
                    ship=~
                    database='db'
                    namespace='ns'
                    name='my-table'
                    alias=~
                    ==
                  as-of=~
                  columns=~
                  :-  %data
                    :~  :~  [~.ud 2.222]
                            [~.ud 2.222]
                            [~.ud 195.198.143.900]
                            [~.rs 1.078.523.331]
                            [~.rs 3.226.006.979]
                            [~.rd 4.614.253.070.214.989.087]
                            [~.rd 13.837.625.107.069.764.895]
                            [~.ux 1.205.249]
                            [~.ub 43]
                            [~.sd 39]
                            [~.sd 40]
                            [~.uw 61.764.130.813.526]
                            [~.uw 1.870.418.170.505.042.572.886]
                            ==
                        ==
              ==
    ==
  =/  urql  "insert into db.ns.my-table ".
            "values (2.222,2222,195.198.143.900,.3.14,.-3.14,.~3.14,".
            ".~-3.14,0x12.6401,10.1011,-20,--20,e2O.l4Xpm,pm.l4e2O.l4Xpm)"
  %+  expect-eq
      !>  expected
      !>  (parse:parse(default-database 'db1') urql)
::
:: upsert, explicit columns and DEFAULT
++  test-upsert-01
  =/  expected
    :+  %crud-txn
        ctes=~
        :-  %upsert
            :*  %upsert
                :*  %qualified-table
                    ship=~
                    database='db1'
                    namespace='dbo'
                    name='my-table'
                    alias=~
                    ==
                as-of=~
                :-  ~
                    ~['id' 'value']
                :-  %data
                    ~[~[[~.ud 1] %default]]
                ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "UPSERT INTO my-table (id, value) VALUES (1, DEFAULT)"
::
:: upsert without explicit columns
++  test-upsert-02
  =/  expected
    :+  %crud-txn
        ctes=~
        :-  %upsert
            :*  %upsert
                :*  %qualified-table
                    ship=~
                    database='db1'
                    namespace='dbo'
                    name='my-table'
                    alias=~
                    ==
                as-of=~
                columns=~
                [%data ~[~[[~.ud 1] [~.ud 2]]]]
                ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "upsert into my-table values (1, 2)"
::
:: upsert with fully qualified table
++  test-upsert-03
  =/  expected
    :+  %crud-txn
        ctes=~
        :-  %upsert
            :*  %upsert
                :*  %qualified-table
                    ship=~
                    database='db'
                    namespace='ns'
                    name='my-table'
                    alias=~
                    ==
                as-of=~
                columns=~
                [%data ~[~[[~.ud 1]]]]
                ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "upsert into db.ns.my-table values (1)"
::
:: upsert with db..table qualified table
++  test-upsert-04
  =/  expected
    :+  %crud-txn
        ctes=~
        :-  %upsert
            :*  %upsert
                :*  %qualified-table
                    ship=~
                    database='db'
                    namespace='dbo'
                    name='my-table'
                    alias=~
                    ==
                as-of=~
                columns=~
                [%data ~[~[[~.ud 1]]]]
                ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "upsert into db..my-table values (1)"
::
:: upsert as of now
++  test-upsert-05
  =/  expected
    :+  %crud-txn
        ctes=~
        :-  %upsert
            :*  %upsert
                :*  %qualified-table
                    ship=~
                    database='db1'
                    namespace='dbo'
                    name='my-table'
                    alias=~
                    ==
                as-of=~
                columns=~
                [%data ~[~[[~.ud 1]]]]
                ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "upsert into my-table as of now values (1)"
::
:: upsert as of concrete date
++  test-upsert-06
  =/  expected
    :+  %crud-txn
        ctes=~
        :-  %upsert
            :*  %upsert
                :*  %qualified-table
                    ship=~
                    database='db1'
                    namespace='dbo'
                    name='my-table'
                    alias=~
                    ==
                as-of=[~ [%da ~2023.12.25..7.15.0..1ef5]]
                columns=~
                [%data ~[~[[~.ud 1]]]]
                ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "upsert into my-table as of ~2023.12.25..7.15.0..1ef5 values (1)"
::
:: upsert as of offset
++  test-upsert-07
  =/  expected
    :+  %crud-txn
        ctes=~
        :-  %upsert
            :*  %upsert
                :*  %qualified-table
                    ship=~
                    database='db1'
                    namespace='dbo'
                    name='my-table'
                    alias=~
                    ==
                as-of=[~ %as-of-offset 5 %days]
                columns=~
                [%data ~[~[[~.ud 1]]]]
                ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "upsert into my-table as of 5 days ago values (1)"
::
:: upsert multiple rows
++  test-upsert-08
  =/  expected
    :+  %crud-txn
        ctes=~
        :-  %upsert
            :*  %upsert
                :*  %qualified-table
                    ship=~
                    database='db1'
                    namespace='dbo'
                    name='my-table'
                    alias=~
                    ==
                as-of=~
                :-  ~
                    ~['id' 'value']
                :-  %data
                    :~  ~[[~.ud 1] [~.ud 2]]
                        ~[[~.ud 1] [~.ud 3]]
                        ==
                ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "upsert into my-table (id, value) values (1, 2) (1, 3)"
::
:: @da as of and values, leading zeros and no leading zeros,
:: with and without ~
++  da-row
  :~  [~.da ~2024.1.5]
      [~.da ~2024.1.5]
      [~.da ~2024.1.5..7.5.9]
      [~.da ~2024.1.5..7.5.9]
      [~.da ~2024.1.5]
      [~.da ~2024.1.5]
      ==
++  da-values
  "values (~2024.01.05, ~2024.1.5, ~2024.01.05..07.05.09, ".
  "~2024.1.5..7.5.9, 2024.01.05, 2024.1.5)"
::
++  test-insert-da-00
  =/  expected
    :+  %crud-txn
        ctes=~
        :-  %insert
            :*  %insert
                :*  %qualified-table
                    ship=~
                    database='db1'
                    namespace='dbo'
                    name='my-table'
                    alias=~
                    ==
                as-of=[~ [%da ~2023.1.5..7.5.9..1ef5]]
                columns=~
                [%data ~[da-row]]
                ==
  %+  expect-eq
    !>  ~[expected expected]
    !>  %-  parse:parse(default-database 'db1')
        %-  zing
        :~  "insert into my-table as of ~2023.01.05..07.05.09..1ef5 "
            da-values
            "; insert into my-table as of ~2023.1.5..7.5.9..1ef5 "
            da-values
            ==
::
++  test-upsert-da-00
  =/  expected
    :+  %crud-txn
        ctes=~
        :-  %upsert
            :*  %upsert
                :*  %qualified-table
                    ship=~
                    database='db1'
                    namespace='dbo'
                    name='my-table'
                    alias=~
                    ==
                as-of=[~ [%da ~2023.1.5..7.5.9..1ef5]]
                columns=~
                [%data ~[da-row]]
                ==
  %+  expect-eq
    !>  ~[expected expected]
    !>  %-  parse:parse(default-database 'db1')
        %-  zing
        :~  "upsert into my-table as of ~2023.01.05..07.05.09..1ef5 "
            da-values
            "; upsert into my-table as of ~2023.1.5..7.5.9..1ef5 "
            da-values
            ==
::
:: fail on invalid month and day forms
++  test-fail-insert-da-00
  %-  expect-fail
  |.  %-  parse:parse(default-database 'db1')
          "insert into my-table values (~2024.00.5)"
::
++  test-fail-insert-da-01
  %-  expect-fail
  |.  %-  parse:parse(default-database 'db1')
          "insert into my-table values (~2024.1.00)"
::
++  test-fail-insert-da-02
  %-  expect-fail
  |.  %-  parse:parse(default-database 'db1')
          "insert into my-table values (~2024.13.5)"
::
++  test-fail-insert-da-03
  %-  expect-fail
  |.  %-  parse:parse(default-database 'db1')
          "insert into my-table values (~2024.012.5)"
::
::  INSERT and UPSERT from a query
::
::  the crud-txn of a query parsed alone
++  query-txn
  |=  urql=tape
  ^-  crud-txn:ast
  ;;(crud-txn:ast (snag 0 (parse:parse(default-database 'db1') urql)))
::
::  the insert source of a query parsed alone
++  query-source
  |=  urql=tape
  ^-  insert-values:ast
  =/  body  body:(query-txn urql)
  ?:  ?=(%query -.body)  body
  ?:  ?=(%set-query -.body)  body
  ~|("query-source: not a query {<urql>}" !!)
::
++  my-table
  ^-  qualified-table:ast
  [%qualified-table ~ 'db1' 'dbo' 'my-table' ~]
::
++  insert-txn
  |=  $:  op=?(%insert %upsert)
          ctes=(list cte:ast)
          as-of=(unit as-of:ast)
          columns=(unit (list @tas))
          source=tape
          ==
  ^-  crud-txn:ast
  =/  ins=insert:ast  [op my-table as-of columns (query-source source)]
  ?:  ?=(%insert op)
    [%crud-txn ctes [%insert ins]]
  [%crud-txn ctes [%upsert ins]]
::
++  parse-db1
  |=  urql=tape
  (parse:parse(default-database 'db1') urql)
::
::  FROM query, no columns
++  test-insert-query-00
  %+  expect-eq
    !>  ~[(insert-txn %insert ~ ~ ~ "FROM foo SELECT a, b")]
    !>  (parse-db1 "INSERT INTO my-table FROM foo SELECT a, b")
::
::  column list, WHERE, extra whitespace, trailing ;
++  test-insert-query-01
  =/  source  "FROM foo WHERE a = 1 SELECT a, b"
  %+  expect-eq
    !>  ~[(insert-txn %insert ~ ~ `~['c1' 'c2'] source)]
    !>  %-  parse-db1
        "insert  into  my-table ( c1 , c2 )  from foo where a = 1 select a, b;"
::
::  SELECT without FROM
++  test-insert-query-02
  %+  expect-eq
    !>  ~[(insert-txn %insert ~ ~ ~ "SELECT 1, 'x'")]
    !>  (parse-db1 "INSERT INTO my-table SELECT 1, 'x'")
::
::  AS OF date and column list
++  test-insert-query-03
  %+  expect-eq
    !>  :~  %:  insert-txn  %insert
                            ~
                            `[%da ~2023.1.5]
                            `~['c1']
                            "FROM foo SELECT a"
                            ==
            ==
    !>  %-  parse-db1
        "INSERT INTO my-table AS OF ~2023.1.5 (c1) FROM foo SELECT a"
::
::  AS OF offset
++  test-insert-query-04
  %+  expect-eq
    !>  :~  %:  insert-txn  %insert
                            ~
                            `[%as-of-offset 5 %days]
                            ~
                            "FROM foo SELECT a"
                            ==
            ==
    !>  (parse-db1 "INSERT INTO my-table AS OF 5 DAYS AGO FROM foo SELECT a")
::
::  set query source
++  test-insert-query-05
  =/  source  "FROM foo SELECT a UNION FROM bar SELECT b"
  %+  expect-eq
    !>  ~[(insert-txn %insert ~ ~ ~ source)]
    !>  (parse-db1 (weld "INSERT INTO my-table " source))
::
::  CTE source
++  test-insert-query-06
  ::  the query parsed with its CTE, so c1 names the CTE
  =/  txn  (query-txn "WITH (FROM foo SELECT a) AS c1 FROM c1 SELECT a")
  =/  source  body.txn
  ?>  ?=(%query -.source)
  =/  ins=insert:ast  [%insert my-table ~ ~ source]
  %+  expect-eq
    !>  `(list crud-txn:ast)`~[[%crud-txn ctes.txn [%insert ins]]]
    !>  %-  parse-db1
        "WITH (FROM foo SELECT a) AS c1 INSERT INTO my-table FROM c1 SELECT a"
::
::  UPSERT from a query
++  test-upsert-query-00
  %+  expect-eq
    !>  ~[(insert-txn %upsert ~ ~ `~['c1'] "FROM foo SELECT a")]
    !>  (parse-db1 "UPSERT INTO my-table (c1) FROM foo SELECT a")
::
::  TOP with ORDER BY; a following command
++  test-insert-query-07
  =/  source  "FROM foo SELECT TOP 2 a ORDER BY a"
  %+  expect-eq
    !>  :~  (insert-txn %insert ~ ~ ~ source)
            (query-txn "FROM bar SELECT b")
            ==
    !>  %-  parse-db1
        "INSERT INTO my-table FROM foo SELECT TOP 2 a ORDER BY a; ".
        "FROM bar SELECT b"
::
::  a VALUES insert after an insert from a query
++  test-insert-query-08
  =/  values=crud-txn:ast
    :+  %crud-txn
        ~
        [%insert [%insert my-table ~ ~ [%data ~[~[[~.ud 1]]]]]]
  %+  expect-eq
    !>  ~[(insert-txn %insert ~ ~ ~ "FROM foo SELECT a") values]
    !>  %-  parse-db1
        "INSERT INTO my-table FROM foo SELECT a; ".
        "INSERT INTO my-table VALUES (1)"
::
::  TOP requires ORDER BY
++  test-fail-insert-query-00
  %+  expect-fail-message
    'TOP requires ORDER BY'
  |.  (parse-db1 "INSERT INTO my-table FROM foo SELECT TOP 2 a")
::
::  a query source needs FROM or SELECT
++  test-fail-insert-query-01
  %-  expect-fail
  |.  (parse-db1 "INSERT INTO my-table (c1) foo SELECT a")
::
::  TOP is not allowed on the last query of a set operation
++  test-fail-insert-query-02
  %+  expect-fail-message
    'TOP is not allowed on the last query of a set operation'
  |.  %-  parse-db1
      "INSERT INTO my-table FROM foo SELECT a UNION FROM bar SELECT TOP 1 b ".
      "ORDER BY b"
--
