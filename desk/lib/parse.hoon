/-  ast
!:
:: a library for parsing urQL tapes
:: use (parse:parse(default-database '<db>') "<script>")
|_  default-database=@tas
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
::  parsed list is a predicate leaf
++  pred-leaf
  |=  parsed=(list raw-pred-cmpnt)
  ^-  predicate:ast
  ?.  ?=(predicate-component:ast -.parsed)
    ~|("unknown predicate node {<-.parsed>}" !!)
  ?+  -.parsed  ~|("unknown predicate leaf {<-.parsed>}" !!)
    qualified-column:ast
      [-.parsed ~ ~]
    dime
      [-.parsed ~ ~]
    aggregate:ast
      [-.parsed ~ ~]
    value-literals:ast
      [-.parsed ~ ~]
  ==
::
::  +parse: parse urQL script, emitting list of high level AST structures
++  parse
  |=  raw-script=tape
  ^-  (list command:ast)
  =/  script=tape  (block-cmnts raw-script)
  =/  commands  `(list command:ast)`~
  =/  parse-command  ;~  pose
    %:  cold  %alter-index
              ;~(plug whitespace (jester 'alter') whitespace (jester 'index'))
              ==
    %:  cold  %alter-namespace
              ;~  plug  whitespace
                        (jester 'alter')
                        whitespace
                        (jester 'namespace')
                        ==
              ==
    %:  cold  %alter-table
              ;~(plug whitespace (jester 'alter') whitespace (jester 'table'))
              ==
    %:  cold  %create-database
              ;~  plug  whitespace
                        (jester 'create')
                        whitespace
                        (jester 'database')
                        ==
              ==
    %:  cold  %create-namespace
              ;~  plug  whitespace
                        (jester 'create')
                        whitespace
                        (jester 'namespace')
                        ==
              ==
    %:  cold  %create-table
              ;~(plug whitespace (jester 'create') whitespace (jester 'table'))
              ==
    %:  cold  %create-view
              ;~(plug whitespace (jester 'create') whitespace (jester 'view'))
              ==
    %:  cold  %create-index                           :: must be last of creates
              ;~(plug whitespace (jester 'create'))
              ==
    %:  cold  %delete
              ;~(plug whitespace (jester 'delete') whitespace (jester 'from'))
              ==
    %:  cold  %delete
              ;~(plug whitespace (jester 'delete'))
              ==
    %:  cold  %drop-database
              ;~(plug whitespace (jester 'drop') whitespace (jester 'database'))
              ==
    %:  cold  %drop-index
              ;~(plug whitespace (jester 'drop') whitespace (jester 'index'))
              ==
    %:  cold  %drop-namespace
              ;~  plug  whitespace
                        (jester 'drop')
                        whitespace
                        (jester 'namespace')
                        ==
              ==
    %:  cold  %drop-table
              ;~(plug whitespace (jester 'drop') whitespace (jester 'table'))
              ==
    %:  cold  %drop-view
              ;~(plug whitespace (jester 'drop') whitespace (jester 'view'))
              ==
    %:  cold  %grant
              ;~(plug whitespace (jester 'grant'))
              ==
    %:  cold  %insert
              ;~(plug whitespace (jester 'insert') whitespace (jester 'into'))
              ==
    %:  cold  %merge
              ;~(plug whitespace (jester 'merge') whitespace (jester 'into'))
              ==
    %:  cold  %merge
              ;~(plug whitespace (jester 'merge') whitespace (jester 'from'))
              ==
    %:  cold  %merge
              ;~(plug whitespace (jester 'merge'))
              ==
    %:  cold  %query
              ;~(plug whitespace (jester 'from'))
              ==
    %:  cold  %query
              ;~  plug  whitespace
                        ;~(pfix (jester 'select') (funk "select" (easy ' ')))
                        ==
              ==
    %:  cold  %revoke
              ;~(plug whitespace (jester 'revoke'))
              ==
    %:  cold  %truncate-table
              ;~  plug  whitespace
                        (jester 'truncate')
                        whitespace
                        (jester 'table')
                        ==
              ==
    %:  cold  %update
              ;~(pfix whitespace (jester 'update'))
              ==
    %:  cold  %with
              ;~(plug whitespace (jester 'with'))
              ==
    ==
  =/  dummy   ~|  'Default database name is not a proper term'
                  (scan (trip default-database) sym)
  :: main loop
  ::
  |-
  ?~  script  (flop commands)
  =/  check-empty  u.+3:q.+3:(whitespace [[1 1] script])  :: trailing whitespace
  ?:  =(0 (lent q.q:check-empty))                  :: after last end-command (;)
    (flop commands)
  =/  command-nail  u.+3:q.+3:(parse-command [[1 1] script])
  ?-  `urql-command`p.command-nail
    %alter-index
      ~|  "alter index error:  {<`tape`(scag 100 q.q.command-nail)>} ..."
      =/  index-nail  (parse-alter-index [[1 1] q.q.command-nail])
      =/  parsed  (wonk index-nail)
      %=  $
        script    q.q.u.+3.q:index-nail
        commands 
                          :: qualifier w/o ship or alias
          :-  ?:  ?=  $:  [%qualified-object ~ @ @ @ ~]
                          [%qualified-object ~ @ @ @ ~]
                          @
                          ==
                      parsed
                %:  alter-index:ast  %alter-index
                                      -.parsed
                                      +<.parsed
                                      ~
                                      +>.parsed
                                      ~
                                      ==
              :: alter index single column
              ?:  ?=  $:  [%qualified-object ~ @ @ @ ~]
                          [%qualified-object ~ @ @ @ ~]
                          [[@ @ @] %~]
                          ==
                      parsed
                %:  alter-index:ast  %alter-index
                                      -.parsed
                                      +<.parsed
                                      +>.parsed
                                      %rebuild
                                      ~
                                      ==
              :: alter index columns action
              ?:  ?=  $:  [%qualified-object ~ @ @ @ ~]
                          [%qualified-object ~ @ @ @ ~]
                          *
                          @
                          ==
                      parsed
                %:  alter-index:ast  %alter-index
                                     -.parsed
                                     +<.parsed
                                     +>-.parsed
                                     +>+.parsed
                                     ~
                                     ==
              :: alter index multiple columns
              ?:  ?=  $:  [%qualified-object ~ @ @ @ ~]
                          [%qualified-object ~ @ @ @ ~]
                          *
                          ==
                      parsed
                %:  alter-index:ast  %alter-index
                                     -.parsed
                                     +<.parsed
                                     +>.parsed
                                     %rebuild
                                     ~
                                     ==
              !!
              commands
      ==
    %alter-namespace
      ~|  "alter namespace error:  {<`tape`(scag 100 q.q.command-nail)>} ..."
      =/  namespace-nail  (parse-alter-namespace [[1 1] q.q.command-nail])
      =/  parsed  (wonk namespace-nail)
      %=  $
        script    q.q.u.+3.q:namespace-nail
        commands
          :-  ?:  =(%as-of +>+<.parsed)
                ?:  =(%now +>+>.parsed)
                  %:  alter-namespace:ast  %alter-namespace
                                          -<.parsed
                                          ->.parsed
                                          +<.parsed
                                          +>->+>-.parsed
                                          +>->+>+<.parsed
                                          ~
                                          ==
                ?:  ?=([@ @] +>+>.parsed)
                  %:  alter-namespace:ast  %alter-namespace
                                          -<.parsed
                                          ->.parsed
                                          +<.parsed
                                          +>->+>-.parsed
                                          +>->+>+<.parsed
                                          [~ +>+>.parsed]
                                          ==
                %:  alter-namespace:ast  %alter-namespace
                                        -<.parsed
                                        ->.parsed
                                        +<.parsed
                                        +>->+>-.parsed
                                        +>->+>+<.parsed
                                        :-  ~
                                            %:  as-of-offset:ast  %as-of-offset
                                                                  +>+>-.parsed
                                                                  +>+>+<.parsed
                                                                  ==
                                        ==
              ::
              %:  alter-namespace:ast  %alter-namespace
                                      -<.parsed
                                      ->.parsed
                                      +<.parsed
                                      +>+>+<.parsed
                                      +>+>+>-.parsed
                                      ~
                                      ==
        commands
      ==
    %alter-table
      ~|  "alter table error:  {<`tape`(scag 100 q.q.command-nail)>} ..."
      =/  table-nail  (parse-alter-table [[1 1] q.q.command-nail])
      =/  parsed  (wonk table-nail)
      ?:  =(+<.parsed %alter-column)
        %=  $
          script    q.q.u.+3.q:table-nail
          commands  :-  %:  alter-table:ast  %alter-table
                                            -.parsed
                                            +>.parsed
                                            ~
                                            ~
                                            ~
                                            ~
                                            ~
                                            ==
                        commands
        ==
      ?:  =(+<.parsed %add-column)
        %=  $
          script    q.q.u.+3.q:table-nail
          commands  :-  %:  alter-table:ast  %alter-table
                                            -.parsed
                                            ~
                                            +>.parsed
                                            ~
                                            ~
                                            ~
                                            ~
                                            ==
                        commands
        ==
      ?:  =(+<.parsed %drop-column)
        %=  $
          script    q.q.u.+3.q:table-nail
          commands  :-  %:  alter-table:ast  %alter-table
                                            -.parsed
                                            ~
                                            ~
                                            +>.parsed
                                            ~
                                            ~
                                            ~
                                            ==
                        commands
        ==
      ?:  =(+<.parsed %add-fk)
        %=  $
          script    q.q.u.+3.q:table-nail
          commands  :-  %:  alter-table:ast  %alter-table
                                            -.parsed
                                            ~
                                            ~
                                            ~
                                            %-  build-foreign-keys
                                                [-.parsed +>.parsed]
                                            ~
                                            ~
                                            ==
                        commands
        ==
      ?:  =(+<.parsed %drop-fk)
        %=  $
          script    q.q.u.+3.q:table-nail
          commands  :-  %:  alter-table:ast  %alter-table
                                            -.parsed
                                            ~
                                            ~
                                            ~
                                            ~
                                            +>.parsed
                                            ~
                                            ==
                        commands
        ==
      ?:  ?&(=(+<-.parsed %alter-column) ?=([* [* %as-of *]] parsed))
        %=  $
          script    q.q.u.+3.q:table-nail
          commands
            ?:  =(%now +>+.parsed)
              :-  %:  alter-table:ast  %alter-table
                                      -.parsed
                                      +<+.parsed
                                      ~
                                      ~
                                      ~
                                      ~
                                      ~
                                      ==
                  commands
            ?:  ?=([@ @] +>+.parsed)
              :-  %:  alter-table:ast  %alter-table
                                      -.parsed
                                      +<+.parsed
                                      ~
                                      ~
                                      ~
                                      ~
                                      [~ +>+.parsed]
                                      ==
                  commands
            :-  %:  alter-table:ast  %alter-table
                                    -.parsed
                                    +<+.parsed
                                    ~
                                    ~
                                    ~
                                    ~
                                    :-  ~
                                       %:  as-of-offset:ast  %as-of-offset
                                                            +>+<.parsed
                                                            +>+>-.parsed
                                                            ==
                                    ==
                commands
        ==
      ?:  ?&(=(+<-.parsed %add-column) ?=([* [* %as-of *]] parsed))
        %=  $
          script    q.q.u.+3.q:table-nail
          commands
            ?:  =(%now +>+.parsed)
              :-  %:  alter-table:ast  %alter-table
                                      -.parsed
                                      ~
                                      +<+.parsed
                                      ~
                                      ~
                                      ~
                                      ~
                                      ==
                  commands
            ?:  ?=([@ @] +>+.parsed)
              :-  %:  alter-table:ast  %alter-table
                                      -.parsed
                                      ~
                                      +<+.parsed
                                      ~
                                      ~
                                      ~
                                      [~ +>+.parsed]
                                      ==
                  commands
            :-  %:  alter-table:ast  %alter-table
                                    -.parsed
                                    ~
                                    +<+.parsed
                                    ~
                                    ~
                                    ~
                                    :-  ~
                                        %:  as-of-offset:ast  %as-of-offset
                                                              +>+<.parsed
                                                              +>+>-.parsed
                                                              ==
                                    ==
                commands
        ==
      ?:  ?&(=(+<-.parsed %drop-column) ?=([* [* %as-of *]] parsed))
        %=  $
          script    q.q.u.+3.q:table-nail
          commands
            ?:  =(%now +>+.parsed)
              :-  %:  alter-table:ast  %alter-table
                                      -.parsed
                                      ~
                                      ~
                                      +<+.parsed
                                      ~
                                      ~
                                      ~
                                      ==
                  commands
            ?:  ?=([@ @] +>+.parsed)
              :-  %:  alter-table:ast  %alter-table
                                      -.parsed
                                      ~
                                      ~
                                      +<+.parsed
                                      ~
                                      ~
                                      [~ +>+.parsed]
                                      ==
                  commands
            :-  %:  alter-table:ast  %alter-table
                                    -.parsed
                                    ~
                                    ~
                                    +<+.parsed
                                    ~
                                    ~
                                    :-  ~
                                        %:  as-of-offset:ast  %as-of-offset
                                                              +>+<.parsed
                                                              +>+>-.parsed
                                                              ==
                                    ==
                commands
        ==
      ?:  ?&(=(+<-.parsed %add-fk) ?=([* [* %as-of *]] parsed))
        %=  $
          script    q.q.u.+3.q:table-nail
          commands
            ?:  =(%now +>+.parsed)
              :-  %:  alter-table:ast  %alter-table
                                      -.parsed
                                      ~
                                      ~
                                      ~
                                      (build-foreign-keys [-.parsed +<+.parsed])
                                      ~
                                      ~
                                      ==
                  commands
            ?:  ?=([@ @] +>+.parsed)
              :-  %:  alter-table:ast  %alter-table
                                      -.parsed
                                      ~
                                      ~
                                      ~
                                      (build-foreign-keys [-.parsed +<+.parsed])
                                      ~
                                      [~ +>+.parsed]
                                      ==
                  commands
            :-  %:  alter-table:ast  %alter-table
                                    -.parsed
                                    ~
                                    ~
                                    ~
                                    (build-foreign-keys [-.parsed +<+.parsed])
                                    ~
                                    :-  ~
                                        %:  as-of-offset:ast  %as-of-offset
                                                              +>+<.parsed
                                                              +>+>-.parsed
                                                              ==
                                    ==
                commands
        ==
      ?:  ?&(=(+<-.parsed %drop-fk) ?=([* [* %as-of *]] parsed))
        %=  $
          script    q.q.u.+3.q:table-nail
          commands
            ?:  =(%now +>+.parsed)
              :-  %:  alter-table:ast  %alter-table
                                      -.parsed
                                      ~
                                      ~
                                      ~
                                      ~
                                      +<+.parsed
                                      ~
                                      ==
                  commands
            ?:  ?=([@ @] +>+.parsed)
              :-  %:  alter-table:ast  %alter-table
                                      -.parsed
                                      ~
                                      ~
                                      ~
                                      ~
                                      +<+.parsed
                                      [~ +>+.parsed]
                                      ==
                  commands
            :-  %:  alter-table:ast  %alter-table
                                    -.parsed
                                    ~
                                    ~
                                    ~
                                    ~
                                    +<+.parsed
                                    :-  ~
                                        %:  as-of-offset:ast  %as-of-offset
                                                              +>+<.parsed
                                                              +>+>-.parsed
                                                              ==
                                    ==
                commands
        ==
      !!
    %create-database
      ~|  "Create database error:  {<(scag 40 q.q.command-nail)>} ..."
      =/  nail  (parse-create-database [[1 1] q.q.command-nail])
      =/  parsed  (wonk nail)
      ?:  ?=([[@ %as-of %now] %end-command ~] parsed)
        %=  $
          script    q.q.u.+3.q:nail
          commands
            [(create-database:ast %create-database -<.parsed ~) commands]
        ==

      ?:  ?=([@ %end-command ~] parsed)
        %=  $
          script    q.q.u.+3.q:nail
          commands  :-  %:  create-database:ast  %create-database
                                                -.parsed
                                                ~
                                                ==
                        commands
        ==
      ?:  ?=([[@ %as-of [%da @]] %end-command ~] parsed)
        %=  $
          script    q.q.u.+3.q:nail
          commands  :-  %:  create-database:ast  %create-database
                                                -<.parsed
                                                [~ ->+.parsed]
                                                ==
                        commands
        ==
      ?:  ?=([[@ %as-of [@ @ %ago]] %end-command ~] parsed)
        %=  $
          script    q.q.u.+3.q:nail
          commands
            :-  %:  create-database:ast  %create-database
                                        -<.parsed
                                        :-  ~
                                        %:  as-of-offset:ast  %as-of-offset
                                                              ->+<.parsed
                                                              ->+>-.parsed
                                                              ==
                                        ==
                commands
        ==
      !!
    %create-index
      ~|  "create index error:  {<`tape`(scag 100 q.q.command-nail)>} ..."
      =/  index-nail  (parse-create-index [[1 1] q.q.command-nail])
      =/  parsed  (wonk index-nail)
      ?:  ?=([@ [* *]] [parsed])                    ::"create index ..."
        %=  $
          script    q.q.u.+3.q:index-nail
          commands  :-  %:  create-index:ast  %create-index
                                      -.parsed
                                      +<.parsed
                                      %.n
                                      +>.parsed
                                      ~
                                      ==
                        commands
        ==
      ?:  ?=([[@ @] [* *]] [parsed])
        ?:  =(-<.parsed %unique)                    ::"create unique index ..."
            %=  $
              script    q.q.u.+3.q:index-nail
              commands  :-  %:  create-index:ast  %create-index
                                                  ->.parsed
                                                  +<.parsed
                                                  %.y
                                                  +>.parsed
                                                  ~
                                                  ==
                            commands
            ==
        !!
      !!
    %create-namespace
      ~|  "create namespace error:  {<(scag 40 q.q.command-nail)>} ..."
      =/  create-ns-nail  (parse-create-namespace [[1 1] q.q.command-nail])
      =/  parsed  (wonk create-ns-nail)
      ?@  parsed
        %=  $
          script    q.q.u.+3.q:create-ns-nail
          commands  :-  %:  create-namespace:ast  %create-namespace
                                                  default-database
                                                  parsed
                                                  ~
                                                  ==
                        commands
        ==
      ?:  ?=([@ @] parsed)
        %=  $
          script    q.q.u.+3.q:create-ns-nail
          commands  :-  %:  create-namespace:ast  %create-namespace
                                                  -.parsed
                                                  +.parsed
                                                  ~
                                                  ==
                        commands
        ==
      =/  id  -.parsed
      ?:  =(%now +>.parsed)
        %=  $
          script        q.q.u.+3.q:create-ns-nail
          commands  ?@  id
            :-  (create-namespace:ast %create-namespace default-database id ~)
                commands
          :-  (create-namespace:ast %create-namespace -.id +.id ~)
              commands
        ==
      =/  asof  +>.parsed
      ?:  ?=([@ @] asof)
        %=  $
          script    q.q.u.+3.q:create-ns-nail
          commands  ?@  id
            :-  %:  create-namespace:ast  %create-namespace
                                          default-database
                                          id
                                          [~ asof]
                                          ==
                commands
          :-  %:  create-namespace:ast  %create-namespace
                                        -.id
                                        +.id
                                        [~ asof]
                                        ==
              commands
        ==
      %=  $
        script    q.q.u.+3.q:create-ns-nail
        commands  ?@  id
          :-  %:  create-namespace:ast  %create-namespace
                                        default-database
                                        id
                                        :-  ~
                                            %:  as-of-offset:ast  %as-of-offset
                                                                  -.asof
                                                                  +<.asof
                                                                  ==
                                        ==
              commands
        :-  %:  create-namespace:ast  %create-namespace
                                      -.id
                                      +.id
                                      :-  ~
                                          %:  as-of-offset:ast  %as-of-offset
                                                                -.asof
                                                                +<.asof
                                                                ==
                                      ==
            commands
      ==
    %create-table
      ~|  "create table error:  {<`tape`(scag 100 q.q.command-nail)>} ..."
      =/  table-nail  (parse-create-table [[1 1] q.q.command-nail])
      =/  parsed  (wonk table-nail)
      ?:  ?=([* * [@ *]] parsed)
        %=  $                                       :: no foreign keys
          script    q.q.u.+3.q:table-nail
          commands  :-  %:  create-table:ast  %create-table
                                              -.parsed
                                              +<.parsed
                                              +>+.parsed
                                              ~
                                              ~
                                              ==
                        commands
        ==
      ?:  ?=([* * [@ *] %as-of %now] parsed)
        %=  $                                       :: no foreign keys
          script    q.q.u.+3.q:table-nail
          commands  :-  %:  create-table:ast  %create-table
                                              -.parsed
                                              +<.parsed
                                              +>->.parsed
                                              ~
                                              ~
                                              ==
                        commands
        ==
      ?:  ?=([* * [@ *] %as-of [@ @]] parsed)
        %=  $                                       :: no foreign keys
          script    q.q.u.+3.q:table-nail
          commands  :-  %:  create-table:ast  %create-table
                                              -.parsed
                                              +<.parsed
                                              +>->.parsed
                                              ~
                                              [~ +>+>.parsed]
                                              ==
                        commands
        ==
      ?:  ?=([* * [@ *] %as-of [@ @ @]] parsed)
        %=  $                                       :: no foreign keys
          script    q.q.u.+3.q:table-nail
          commands
            :-  %:  create-table:ast  %create-table
                                      -.parsed
                                      +<.parsed
                                      +>->.parsed
                                      ~
                                      :-  ~
                                          %:  as-of-offset:ast  %as-of-offset
                                                                +>+>-.parsed
                                                                +>+>+<.parsed
                                                                ==
                                      ==
                commands
        ==
      ?:  ?=([* * * %as-of %now] parsed)
        %=  $
          script    q.q.u.+3.q:table-nail
          commands  :-  %:  create-table:ast  %create-table
                                              -.parsed
                                              +<.parsed
                                              +>-<+.parsed
                                              %-  build-foreign-keys
                                                  [-.parsed +>->.parsed]
                                              ~
                                              ==
                        commands
        ==
      ?:  ?=([* * * %as-of [@ @]] parsed)
        %=  $
          script    q.q.u.+3.q:table-nail
          commands  :-  %:  create-table:ast  %create-table
                                              -.parsed
                                              +<.parsed
                                              +>-<+.parsed
                                              %-  build-foreign-keys
                                                  [-.parsed +>->.parsed]
                                              [~ +>+>+.parsed]
                                              ==
                        commands
        ==
      ?:  ?=([* * * %as-of [@ @ @]] parsed)
        %=  $
          script    q.q.u.+3.q:table-nail
          commands  :-  %:  create-table:ast  %create-table
                                              -.parsed
                                              +<.parsed
                                              +>-<+.parsed
                                              %-  build-foreign-keys
                                                  [-.parsed +>->.parsed]
                                              :-  ~
                                                  %:  as-of-offset:ast
                                                        %as-of-offset
                                                        +>+>-.parsed
                                                        +>+>+<.parsed
                                                        ==
                                              ==
                        commands
        ==
      %=  $
        script    q.q.u.+3.q:table-nail
        commands  :-  %:  create-table:ast  %create-table
                                            -.parsed
                                            +<.parsed
                                            +>->.parsed
                                            %-  build-foreign-keys
                                                [-.parsed +>+.parsed]
                                            ~
                                            ==
                      commands
      ==
    %create-view
      ~|  "create view error:  {<`tape`(scag 100 q.q.command-nail)>} ..."
      !!
    %delete
      ~|  "delete error:  {<`tape`(scag 100 q.q.command-nail)>} ..."
      =/  delete-nail  (parse-delete [[1 1] q.q.command-nail])
      =/  parsed  (wonk delete-nail)
      %=  $
        script    q.q.u.+3.q:delete-nail
        commands  :-  %:  selection:ast  %selection
                                        ~
                                        [(produce-delete parsed) ~ ~]
                                        ==
                      commands
      ==
    %drop-database
      ~|  "drop database error:  {<`tape`(scag 100 q.q.command-nail)>} ..."
      =/  drop-database-nail  (parse-drop-database [[1 1] q.q.command-nail])
      =/  parsed  (wonk drop-database-nail)
      ?@  parsed                                    :: name
        %=  $
          script    q.q.u.+3.q:drop-database-nail
          commands  [(drop-database:ast %drop-database parsed %.n) commands]
        ==
      ?:  ?=([@ @] parsed)                          :: force name
        %=  $
          script    q.q.u.+3.q:drop-database-nail
          commands  [(drop-database:ast %drop-database +.parsed %.y) commands]
        ==
      !!
    %drop-index
      ~|  "drop index error:  {<`tape`(scag 100 q.q.command-nail)>} ..."
      =/  drop-index-nail  (parse-drop-index [[1 1] q.q.command-nail])
      =/  parsed  (wonk drop-index-nail)
      %=  $
        script    q.q.u.+3.q:drop-index-nail
        commands  [(drop-index:ast %drop-index -.parsed +.parsed ~) commands]
      ==
    %drop-namespace
      ~|  "drop namespace error:  {<`tape`(scag 100 q.q.command-nail)>} ..."
      =/  drop-namespace-nail  (parse-drop-namespace [[1 1] q.q.command-nail])
      =/  parsed  (wonk drop-namespace-nail)
      ?@  parsed                                    :: name
        %=  $
          script    q.q.u.+3.q:drop-namespace-nail
          commands  :-  %:  drop-namespace:ast  %drop-namespace
                                                default-database
                                                parsed
                                                %.n
                                                ~
                                                ==
                        commands
        ==
      ?:  ?=([@ %as-of *] parsed)                   :: name as of
        %=  $
          script    q.q.u.+3.q:drop-namespace-nail
          commands
            ?:  =(%now +>.parsed)
              :-  %:  drop-namespace:ast  %drop-namespace
                                          default-database
                                          -.parsed
                                          %.n
                                          ~
                                          ==
                  commands
            ?:  ?=([@ @] +>.parsed)
              :-  %:  drop-namespace:ast  %drop-namespace
                                          default-database
                                          -.parsed
                                          %.n
                                          [~ +>.parsed]
                                          ==
                  commands
            :-  %:  drop-namespace:ast  %drop-namespace
                                        default-database
                                        -.parsed
                                        %.n
                                        :-  ~
                                            %:  as-of-offset:ast  %as-of-offset
                                                                  +>-.parsed
                                                                  +>+<.parsed
                                                                  ==
                                        ==
                commands
        ==
      ?:  ?=([[%force @] %as-of *] parsed)          :: force name as of
        %=  $
          script    q.q.u.+3.q:drop-namespace-nail
          commands
            ?:  =(%now +>.parsed)
              :-  %:  drop-namespace:ast  %drop-namespace
                                          default-database
                                          ->.parsed
                                          %.y
                                          ~
                                          ==
                  commands
            ?:  ?=([@ @] +>.parsed)
              :-  %:  drop-namespace:ast  %drop-namespace
                                          default-database
                                          ->.parsed
                                          %.y
                                          [~ +>.parsed]
                                          ==
                  commands
            :-  %:  drop-namespace:ast  %drop-namespace
                                        default-database
                                        ->.parsed
                                        %.y
                                        :-  ~
                                            %:  as-of-offset:ast  %as-of-offset
                                                                  +>-.parsed
                                                                  +>+<.parsed
                                                                  ==
                                        ==
                commands
        ==
      ?:  ?=([[@ @] %as-of *] parsed)                   :: name as of
        %=  $
          script    q.q.u.+3.q:drop-namespace-nail
          commands
            ?:  =(%now +>.parsed)
              :-  (drop-namespace:ast %drop-namespace -<.parsed ->.parsed %.n ~)
                  commands
            ?:  ?=([@ @] +>.parsed)
              :-  %:  drop-namespace:ast  %drop-namespace
                                          -<.parsed
                                          ->.parsed
                                          %.n
                                          [~ +>.parsed]
                                          ==
                  commands
            :-  %:  drop-namespace:ast  %drop-namespace
                                        -<.parsed
                                        ->.parsed
                                        %.n
                                        :-  ~
                                            %:  as-of-offset:ast  %as-of-offset
                                                                  +>-.parsed
                                                                  +>+<.parsed
                                                                  ==
                                        ==
                commands
        ==
      ?:  ?=([[%force [@ @]] %as-of *] parsed)            :: force db.name as of
        %=  $
          script    q.q.u.+3.q:drop-namespace-nail
          commands
            ?:  =(%now +>.parsed)
              :-  %:  drop-namespace:ast  %drop-namespace
                                          ->-.parsed
                                          ->+.parsed
                                          %.y
                                          ~
                                          ==
                  commands
            ?:  ?=([@ @] +>.parsed)
              :-  %:  drop-namespace:ast  %drop-namespace
                                          ->-.parsed
                                          ->+.parsed
                                          %.y
                                          [~ +>.parsed]
                                          ==
                  commands
            :-  %:  drop-namespace:ast  %drop-namespace
                                        ->-.parsed
                                        ->+.parsed
                                        %.y
                                        :-  ~
                                            %:  as-of-offset:ast  %as-of-offset
                                                                  +>-.parsed
                                                                  +>+<.parsed
                                                                  ==
                                        ==
                commands
        ==
      ?:  ?=([%force @] parsed)                     :: force name
          %=  $
            script    q.q.u.+3.q:drop-namespace-nail
            commands  :-  %:  drop-namespace:ast  %drop-namespace
                                                  default-database
                                                  +.parsed
                                                  %.y
                                                  ~
                                                  ==
                          commands
          ==
      ?:  ?=([@ @] parsed)                          :: db.name
        %=  $
          script    q.q.u.+3.q:drop-namespace-nail
          commands  :-  %:  drop-namespace:ast  %drop-namespace
                                                -.parsed
                                                +.parsed
                                                %.n
                                                ~
                                                ==
                        commands
        ==
      ?:  ?=([%force [@ @]] parsed)                      :: force db.name
        %=  $
          script    q.q.u.+3.q:drop-namespace-nail
          commands  :-  %:  drop-namespace:ast  %drop-namespace
                                                +<.parsed
                                                +>.parsed
                                                %.y
                                                ~
                                                ==
                        commands
        ==
      !!
    %drop-table
      ~|  "drop table error:  {<`tape`(scag 100 q.q.command-nail)>} ..."
      =/  drop-table-nail  (parse-drop-table-view [[1 1] q.q.command-nail])
      =/  parsed  (wonk drop-table-nail)
      ?:  ?=([[%force *] %as-of *] parsed)   :: force qualified table name as of
        %=  $
          script           q.q.u.+3.q:drop-table-nail
          commands
            ?:  =(%now +>.parsed)
              [(drop-table:ast %drop-table ->.parsed %.y ~) commands]
            ?:  ?=([@ @] +>.parsed)
              :-  (drop-table:ast %drop-table ->.parsed %.y [~ +>.parsed])
                  commands
            :-  %:  drop-table:ast  %drop-table
                                    ->.parsed
                                    %.y
                                    :-  ~
                                        %:  as-of-offset:ast  %as-of-offset
                                                              +>-.parsed
                                                              +>+<.parsed
                                                              ==
                                    ==
                commands
        ==
      ?:  ?=([* %as-of *] parsed)    :: qualified table name as of
        %=  $
          script           q.q.u.+3.q:drop-table-nail
          commands
            ?:  =(%now +>.parsed)
              [(drop-table:ast %drop-table -.parsed %.n ~) commands]
            ?:  ?=([@ @] +>.parsed)
              :-  (drop-table:ast %drop-table -.parsed %.n [~ +>.parsed])
                  commands
            :-  %:  drop-table:ast  %drop-table
                                    -.parsed
                                    %.n
                                    :-  ~
                                        %:  as-of-offset:ast  %as-of-offset
                                                              +>-.parsed
                                                              +>+<.parsed
                                                              ==
                                    ==
                commands
        ==
      ?:  ?=([@ @ @ @ @ @ @] parsed)               :: force qualified table name
        %=  $
          script    q.q.u.+3.q:drop-table-nail
          commands  [(drop-table:ast %drop-table +.parsed %.y ~) commands]
        ==
      ?:  ?=([@ @ @ @ @ @] parsed)                    :: qualified table name
        %=  $
          script    q.q.u.+3.q:drop-table-nail
          commands  [(drop-table:ast %drop-table parsed %.n ~) commands]
        ==
      !!
    %drop-view
      ~|  "drop view error:  {<`tape`(scag 100 q.q.command-nail)>} ..."
      =/  drop-view-nail  (parse-drop-table-view [[1 1] q.q.command-nail])
      =/  parsed  (wonk drop-view-nail)
      ?:  ?=([@ @ @ @ @ @ @] parsed)                  :: force qualified view
        %=  $
          script    q.q.u.+3.q:drop-view-nail
          commands  [(drop-view:ast %drop-view +.parsed %.y) commands]
        ==
      ?:  ?=([@ @ @ @ @ @] parsed)                    :: qualified view
        %=  $
          script    q.q.u.+3.q:drop-view-nail
          commands  [(drop-view:ast %drop-view parsed %.n) commands]
        ==
      !!
    %grant
      ~|  "grant error:  {<`tape`(scag 100 q.q.command-nail)>} ..."
      =/  grant-nail  (parse-grant [[1 1] q.q.command-nail])
      =/  parsed  (wonk grant-nail)
      %=  $
        script    q.q.u.+3.q:grant-nail
        commands  :-  %:  grant:ast  %grant
                                     -.parsed
                                     +<.parsed
                                     +>-.parsed
                                     +>+.parsed
                                     ==
                      commands
      ==
    %insert
      ~|  "insert error:  {<`tape`(scag 100 q.q.command-nail)>} ..."
      =/  insert-nail
            ::~>  %bout.[0 %parse-insert]  
            (parse-insert [[1 1] q.q.command-nail])
      =/  parsed  (wonk insert-nail)
      =/  ins
            ::~>  %bout.[0 %parse-produce-insert]  
            (produce-insert parsed)
      %=  $
        script    q.q.u.+3.q:insert-nail
        commands  :-  (selection:ast %selection ~ [ins ~ ~])
                      commands
      ==
    %merge
      ~|  "merge error:  {<`tape`(scag 100 q.q.command-nail)>} ..."
      =/  merge-nail  (parse-merge [[1 1] q.q.command-nail])
      =/  parsed  (wonk merge-nail)
      %=  $
        script    q.q.u.+3.q:merge-nail
        commands  :-  (selection:ast %selection ~ [(produce-merge parsed) ~ ~])
                      commands
      ==
    %query
      ~|  "query error:  {<`tape`(scag 100 q.q.command-nail)>} ..."
      =/  query-nail  (parse-query [[1 1] q.q.command-nail])
      =/  parsed  (wonk query-nail)
      %=  $
        script    q.q.u.+3.q:query-nail
        commands  :-  (selection:ast %selection ~ [(produce-query parsed) ~ ~])
                      commands
      ==
    %revoke
      ~|  "revoke error:  {<`tape`(scag 100 q.q.command-nail)>} ..."
      =/  revoke-nail  (parse-revoke [[1 1] q.q.command-nail])
      =/  parsed  (wonk revoke-nail)
      %=  $
        script    q.q.u.+3.q:revoke-nail
        commands  :-  %:  revoke:ast  %revoke
                                      -.parsed
                                      +<.parsed
                                      +>-.parsed
                                      +>+.parsed
                                      ==
                      commands
      ==
    %truncate-table
      ~|  "truncate table error:  {<`tape`(scag 100 q.q.command-nail)>} ..."
      =/  truncate-table-nail  (parse-truncate-table [[1 1] q.q.command-nail])
      =/  parsed  (wonk truncate-table-nail)
      %=  $
        script    q.q.u.+3.q:truncate-table-nail
        commands
          :-  ?:  ?=(qualified-object:ast parsed)
                %^  truncate-table:ast  %truncate-table
                                        parsed
                                        ~
              ?:  ?=([qualified-object:ast %as-of [@ @ @]] parsed)
                %^  truncate-table:ast  %truncate-table
                                        -.parsed
                                        :-  ~
                                            %^  as-of-offset:ast  %as-of-offset
                                                                  +>-.parsed
                                                                  +>+<.parsed
              ?:  ?=([qualified-object:ast %as-of %now] parsed)
                %^  truncate-table:ast  %truncate-table
                                        -.parsed
                                        ~
              ?:  ?=([qualified-object:ast %as-of [@ @]] parsed)
                %^  truncate-table:ast  %truncate-table
                                        -.parsed  
                                        [~ +>.parsed]
              !!
              commands
      ==
    %update
      ~|  "update error:  {<`tape`(scag 100 q.q.command-nail)>} ..."
      =/  update-nail  (parse-update [[1 1] q.q.command-nail])
      =/  parsed  (wonk update-nail)
      %=  $
        script           q.q.u.+3.q:update-nail
        commands
          [(selection:ast %selection ~ [(produce-update parsed) ~ ~]) commands]
      ==
    %with
      ~|  "with error:  {<`tape`(scag 100 q.q.command-nail)>} ..."
      =/  with-nail  (parse-with [[1 1] q.q.command-nail])
      =/  parsed  (wonk with-nail)
      ?:  =(+<.parsed %delete)
        %=  $
          script    q.q.u.+3.q:with-nail
          commands  :-  %:  selection:ast  %selection
                                          (produce-ctes -.parsed)
                                          [(produce-delete +>.parsed) ~ ~]
                                          ==
                        commands
        ==
      ?:  =(+<.parsed %insert)
        %=  $
          script    q.q.u.+3.q:with-nail
          commands  :-  %:  selection:ast  %selection
                                          (produce-ctes -.parsed)
                                          [(produce-insert +>.parsed) ~ ~]
                                          ==
                        commands
        ==
      ?:  =(+<.parsed %merge)
        %=  $
          script    q.q.u.+3.q:with-nail
          commands  :-  %:  selection:ast  %selection
                                          (produce-ctes -.parsed)
                                          [(produce-merge +>.parsed) ~ ~]
                                          ==
                        commands
        ==
      ?:  =(+<.parsed %query)
        %=  $
          script    q.q.u.+3.q:with-nail
          commands  :-  %:  selection:ast  %selection
                                          (produce-ctes -.parsed)
                                          [(produce-query +>.parsed) ~ ~]
                                          ==
                        commands
        ==
      ?:  =(+<.parsed %update)
        %=  $
          script    q.q.u.+3.q:with-nail
          commands  :-  %:  selection:ast  %selection
                                          (produce-ctes -.parsed)
                                          [(produce-update +>.parsed) ~ ~]
                                          ==
                        commands
        ==
      !!
  ==
+$  urql-command
  $%
    %alter-index
    %alter-namespace
    %alter-table
    %create-database
    %create-index
    %create-namespace
    %create-table
    %create-view
    %delete
    %drop-database
    %drop-index
    %drop-namespace
    %drop-table
    %drop-view
    %grant
    %insert
    %merge
    %query
    %revoke
    %truncate-table
    %update
    %with
  ==
::
::  parse urQL commands
::
++  parse-alter-index  ~+
  =/  columns  ;~(pfix whitespace ordered-column-list)
  =/  action  ;~  pfix  whitespace
                       ;~  pose  (jester 'rebuild')
                                (jester 'disable')
                                (jester 'resume')
                                ==
                       ==
  ;~  plug
    ;~(pfix whitespace parse-qualified-3object)
    ;~  pfix  whitespace
              ;~(pfix (jester 'on') ;~(pfix whitespace parse-qualified-3object))
              ==
    ;~(sfix ;~(pose ;~(plug columns action) columns action) end-or-next-command)
  ==
++  parse-alter-namespace  ~+
  ;~  plug
    %:  cook  |=(a=* (qualified-namespace [a default-database]))
              parse-qualified-2-name
              ==
    ;~  pfix  ;~(plug whitespace (jester 'transfer'))
              ;~(pfix whitespace ;~(pose (jester 'table') (jester 'view')))
              ==
    ;~  sfix
      ;~  pose
      ;~(plug ;~(pfix whitespace parse-qualified-3object) parse-as-of)
      ;~(pfix whitespace parse-qualified-3object)
      ==
      end-or-next-command
    ==
  ==
++  parse-alter-table  ~+
  ;~  plug
    ;~(pfix whitespace parse-qualified-3object)
    ;~  sfix
      ;~  pose
        ;~  plug
          ;~  pfix  whitespace
                    ;~  pose  alter-columns
                              add-columns
                              drop-columns
                              add-foreign-key
                              drop-foreign-key
                              ==
                    ==
          parse-as-of
        ==
        ;~  pfix  whitespace
                  ;~  pose  alter-columns
                            add-columns
                            drop-columns
                            add-foreign-key
                            drop-foreign-key
                            ==
                  ==
      ==
      end-or-next-command
    ==
  ==
++  parse-create-database  ~+
  ;~  plug
    ;~  pose
      ;~(plug parse-face parse-as-of)
      parse-face
    ==
    end-or-next-command
  ==
++  parse-create-namespace  ~+
  ;~  sfix
    ;~  pose
      ;~(plug parse-qualified-2-name parse-as-of)
      parse-qualified-2-name
    ==
    end-or-next-command
  ==
++  parse-create-index  ~+
  =/  unique  ;~(pfix whitespace (jester 'unique'))
  =/  index-name  ;~(pfix whitespace (jester 'index') parse-face)
  =/  type-and-name  ;~  pose
    ;~(plug unique index-name)
    index-name
    ==
  ;~  plug
    type-and-name
    ;~  pfix  whitespace
              ;~(pfix (jester 'on') ;~(pfix whitespace parse-qualified-3object))
              ==
    ;~(sfix ordered-column-list end-or-next-command)
  ==
++  parse-create-table  ~+
  ;~  sfix
    ;~  pose
      ;~  plug
        ;~(pfix whitespace parse-qualified-3object)
        column-definitions
        ;~  pose
          ;~  plug  primary-key
                    ;~(pfix foreign-key-literal (more com full-foreign-key))
                    ==
          primary-key
          ==
        parse-as-of
      ==
      ;~  plug
        ;~(pfix whitespace parse-qualified-3object)
        column-definitions
        ;~  pose
          ;~  plug  primary-key
                    ;~(pfix foreign-key-literal (more com full-foreign-key))
                    ==
          primary-key
          ==
      ==
    ==
    end-or-next-command
  ==
++  parse-delete  ~+
  ;~  pose
    ;~  plug
      ;~(pfix whitespace parse-qualified-3object)
      parse-as-of
      ;~  pfix  whitespace
                ;~  plug  (cold %where (jester 'where'))
                          parse-predicate
                          end-or-next-command
                          ==
                ==
      ==
    ;~  plug
      ;~(pfix whitespace parse-qualified-3object)
      ;~  pfix  whitespace
                ;~  plug  (cold %where (jester 'where'))
                          parse-predicate
                          end-or-next-command
                          ==
                ==
      ==
    ==
++  parse-drop-database  ~+
  ;~  sfix
    ;~  pose
      ;~(plug ;~(pfix whitespace (jester 'force')) ;~(pfix whitespace sym))
      ;~(pfix whitespace sym)
      ==
    end-or-next-command
  ==
++  parse-drop-index  ~+
  ;~  sfix
    ;~  pfix
      whitespace
      ;~  plug
        parse-face
        ;~  pfix
          whitespace
          ;~(pfix (jester 'on') ;~(pfix whitespace parse-qualified-3object))
          ==
        ==
      ==
    end-or-next-command
  ==
++  parse-drop-namespace  ~+
  ;~  sfix
    ;~  pose
      ;~  plug
        ;~  pose
          ;~  plug
            ;~(pfix whitespace (cold %force (jester 'force')))
            parse-qualified-2-name
            ==
          parse-qualified-2-name
          ==
        parse-as-of
        ==
      ;~  pose
        ;~  plug
          ;~(pfix whitespace (cold %force (jester 'force')))
          parse-qualified-2-name
          ==
        parse-qualified-2-name
        ==
    ==
    end-or-next-command
  ==
++  parse-drop-table-view  ~+
  ;~  sfix
    ;~  pose
      ;~  plug
        ;~  pose
          ;~(pfix whitespace ;~(plug (jester 'force') parse-qualified-3object))
          parse-qualified-3object
          ==
        parse-as-of
        ==
      ;~  pose
        ;~(pfix whitespace ;~(plug (jester 'force') parse-qualified-3object))
        parse-qualified-3object
        ==
    ==
    end-or-next-command
  ==
++  parse-grant  ~+
  ;~  plug
    :: permission
    ;~  pfix
      whitespace
      ;~(pose (jester 'adminread') (jester 'readonly') (jester 'readwrite'))
      ==
    :: grantees
    ;~  pfix  whitespace
              ;~  pfix  (jester 'to')
                        parse-ship-paths
                        ==
              ==
    :: grant-objects
    parse-grant-objects
    ;~(sfix parse-grant-duration end-or-next-command)
  ==
++  parse-grant-duration
  ;~  pose  ;~  plug  (easy ~)
                      ;~  pfix  ;~(plug whitespace (jester 'for') whitespace)
                                ;~(pfix sig crub-no-text)
                                ==
                      ;~  pfix  ;~  plug  whitespace
                                          (jester 'starting')
                                          whitespace
                                          ==
                                ;~(plug (easy ~) ;~(pfix sig crub-no-text))
                                ==
                      ==
            ;~  plug  (easy ~)
                      ;~  pfix  ;~(plug whitespace (jester 'for') whitespace)
                                ;~(pfix sig crub-no-text)
                                ==
                      ;~  plug  (easy ~)
                                ;~(pfix whitespace ;~(pfix sig crub-no-text))
                                ==
                      ==
            ;~  plug  (easy ~)
                      ;~  pfix  ;~(plug whitespace (jester 'for') whitespace)
                                ;~(pfix sig crub-no-text)
                                ==
                      ;~  pfix  ;~(plug whitespace (jester 'to') whitespace)
                                ;~(plug (easy ~) ;~(pfix sig crub-no-text))
                                ==
                      ==
            (easy ~)
            ==
++  parse-ship-paths
  %+  more  com
            ;~  pose  ;~(pfix whitespace ;~(sfix parse-ship-agent whitespace))
                      ;~(pfix whitespace parse-ship-agent)
                      ;~(sfix parse-ship-agent whitespace)
                      parse-ship-agent
                      ==
++  parse-ship-agent
  ;~  pose  ;~  plug   (stag ~.tas (jester 'parent'))
                       (stag ~ ;~(pfix whitespace stap))
                       ==
            ;~(plug (stag ~.tas (jester 'parent')) (easy ~))
            ::
            ;~  plug  (stag ~.tas (jester 'siblings'))
                      (stag ~ ;~(pfix whitespace stap))
                      ==
            ;~(plug (stag ~.tas (jester 'siblings')) (easy ~))
            ::
            ;~  plug  (stag ~.tas (jester 'moons'))
                      (stag ~ ;~(pfix whitespace stap))
                      ==
            ;~(plug (stag ~.tas (jester 'moons')) (easy ~))
            ::
            ;~  plug  (stag ~.tas (jester 'our'))
                      (stag ~ ;~(pfix whitespace stap))
                      ==
            ;~(plug (stag ~.tas (jester 'our')) (easy ~))
            ::
            ;~(plug (stag ~.p parse-ship) (stag ~ ;~(pfix whitespace stap)))
            ;~(plug (stag ~.p parse-ship) (easy ~))
            ==
++  parse-ship  ;~(pfix sig fed:ag)
++  parse-grant-objects
  ;~  pfix
    whitespace
    ;~  pfix
      (jester 'on')
      %+  more  com  
                ;~  pose  ;~  pfix  whitespace
                                    ;~(sfix parse-grant-object whitespace)
                                    ==
                          ;~(pfix whitespace parse-grant-object)
                          ;~(sfix parse-grant-object whitespace)
                          parse-grant-object
                          ==
    ==
  ==
++  parse-grant-object
  ;~  pose  (stag %server (jester 'server'))
            on-database
            on-namespace
            (stag %table-column stap)
            (stag %table-set parse-qualified-3object)
            ==
++  parse-insert  ~+
  ;~  plug
    ;~  pose
      ;~  plug
        ;~(pfix whitespace parse-qualified-object)
        parse-as-of
        ;~  pose
          ;~(plug face-list ;~(pfix whitespace (jester 'values')))
          ;~(pfix whitespace (jester 'values'))
          ==
        ;~  pfix
          whitespace
          (more whitespace (ifix [pal par] (more com parse-insert-value)))
          ==
      ==
      ;~  plug
        ;~(pfix whitespace parse-qualified-object)
        ;~  pose
          ;~(plug face-list ;~(pfix whitespace (jester 'values')))
          ;~(pfix whitespace (jester 'values'))
          ==
        ;~  pfix
          whitespace
          (more whitespace (ifix [pal par] (more com parse-insert-value)))
          ==
      ==
    ==
    end-or-next-command
  ==
++  parse-query  ~+
  ;~  pose
    parse-query01
    parse-query02
    parse-query03
    parse-query04
    parse-query05
    parse-query06
    parse-query07
    parse-query08
    parse-query09
    parse-query10
  ==
++  parse-query01  ~+
  ;~  plug
    parse-object-and-joins
    ::  (stag %scalars (star parse-scalar))
    ;~(pfix whitespace ;~(plug (cold %where (jester 'where')) parse-predicate))
    parse-group-by
    parse-select
    parse-order-by
    end-or-next-command
  ==
++  parse-query02  ~+
  ;~  plug
    parse-object-and-joins
    ::  (stag %scalars (star parse-scalar))
    ;~(pfix whitespace ;~(plug (cold %where (jester 'where')) parse-predicate))
    parse-group-by
    parse-select
    end-or-next-command
  ==
++  parse-query03  ~+
  ;~  plug
    parse-object-and-joins
    ::  (stag %scalars (star parse-scalar))
    ;~(pfix whitespace ;~(plug (cold %where (jester 'where')) parse-predicate))
    parse-select
    parse-order-by
    end-or-next-command
  ==
++  parse-query04  ~+
  ;~  plug
    parse-object-and-joins
    ::  (stag %scalars (star parse-scalar))
    ;~(pfix whitespace ;~(plug (cold %where (jester 'where')) parse-predicate))
    parse-select
    end-or-next-command
  ==
++  parse-query05  ~+
  ;~  plug
    parse-object-and-joins
    ::  (stag %scalars (star parse-scalar))
    parse-select
    parse-order-by
    end-or-next-command
  ==
++  parse-query06  ~+
  ;~  plug
    parse-object-and-joins
    ::  (stag %scalars (star parse-scalar))
    parse-select
    end-or-next-command
  ==
++  parse-query07  ~+
  ;~  plug
    parse-object-and-joins
    ::  (stag %scalars (star parse-scalar))
    parse-group-by
    parse-select
    parse-order-by
    end-or-next-command
  ==
++  parse-query08  ~+
  ;~  plug
    parse-object-and-joins
    ::  (stag %scalars (star parse-scalar))
    parse-group-by
    parse-select
    end-or-next-command
  ==
++  parse-query09  ~+
  ;~  plug
    parse-object-and-joins
    parse-select
    end-or-next-command
  ==
++  parse-query10  ~+
  ;~  plug
    parse-select
    end-or-next-command
  ==
++  parse-matching-predicate  ~+
  ;~  plug
    (cold %predicate ;~(plug whitespace (jester 'and')))
    parse-predicate
  ==
++  parse-merge-when  ~+
  ;~  plug
    ;~  pose
      ;~  plug
        (cold %matched ;~(plug (jester 'when') whitespace (jester 'matched')))
        parse-matching-predicate
        ==
      (cold %matched ;~(plug (jester 'when') whitespace (jester 'matched')))
      ;~  plug
        %:  cold  %unmatch-target
                  ;~  plug  (jester 'when')
                            whitespace
                            (jester 'not')
                            whitespace
                            (jester 'matched')
                            whitespace
                            (jester 'by')
                            whitespace
                            (jester 'target')
                            ==
                  ==
        parse-matching-predicate
        ==
       %:  cold  %unmatch-target
                ;~  plug  (jester 'when')
                          whitespace
                          (jester 'not')
                          whitespace
                          (jester 'matched')
                          whitespace
                          (jester 'by')
                          whitespace
                          (jester 'target')
                          ==
                ==
      ;~  plug
         %:  cold  %unmatch-target
                  ;~  plug  (jester 'when')
                            whitespace
                            (jester 'not')
                            whitespace
                            (jester 'matched')
                            ==
                  ==
        parse-matching-predicate
        ==
       %:  cold  %unmatch-target
                ;~  plug  (jester 'when')
                          whitespace
                          (jester 'not')
                          whitespace
                          (jester 'matched')
                          ==
                ==
      ;~  plug
         %:  cold  %unmatch-source
                  ;~  plug  (jester 'when')
                            whitespace
                            (jester 'not')
                            whitespace
                            (jester 'matched')
                            whitespace
                            (jester 'by')
                            whitespace
                            (jester 'source')
                            ==
                  ==
        parse-matching-predicate
        ==
       %:  cold  %unmatch-source
                ;~  plug  (jester 'when')
                          whitespace
                          (jester 'not')
                          whitespace
                          (jester 'matched')
                          whitespace
                          (jester 'by')
                          whitespace
                          (jester 'source')
                          ==
                ==
    ==
    ;~  pose
      ;~  plug
         %:  cold  %update
                  ;~  pose
                    ;~  plug  whitespace
                              (jester 'then')
                              whitespace
                              (jester 'update')
                              whitespace
                              (jester 'set')
                              ==
                    ;~  plug  whitespace
                              (jester 'then')
                              whitespace
                              (jester 'update')
                              ==
                    ==
                  ==
        (more com update-column)
      ==
      ;~  plug
         %:  cold  %insert
                  ;~  plug  whitespace
                            (jester 'then')
                            whitespace
                            (jester 'insert')
                            ==
                  ==
      ;~  pose
        ;~(plug face-list ;~(pfix whitespace (jester 'values')))
        ;~(pfix whitespace (jester 'values'))
        ==
      ;~  pfix
        whitespace
         %:  more  whitespace
                  %:  ifix  [pal par]
                            %:  more
                              com
                              ;~(pose parse-qualified-column parse-insert-value)
                              ==
                            ==
                  ==
        ==
      ==
    ==
  ==
++  parse-merge  ~+
  ;~  plug
    ;~  pose
      ;~  pfix  whitespace
                ;~  plug  parse-qualified-object
                          ;~(pfix whitespace ;~(pfix (jester 'as') parse-alias))
                          ==
                ==
      ;~  pfix  whitespace
                ;~  plug  (stag %query-row face-list)
                          ;~(pfix whitespace ;~(pfix (jester 'as') parse-alias))
                          ==
                ==
      ;~  pfix  whitespace
                ;~  plug  parse-qualified-object
                          (cold %as whitespace)
                          ;~(less merge-stop parse-alias)
                          ==
                ==
      ;~  pfix  whitespace
                ;~  plug  (stag %query-row face-list)
                          ;~(pfix whitespace ;~(less merge-stop parse-alias))
                          ==
                ==
      ;~(pfix whitespace parse-qualified-object)
      ;~(pfix whitespace (stag %query-row face-list))
    ==
    ;~  pose
        ;~  plug  (cold %using ;~(plug whitespace (jester 'using') whitespace))
                  ;~  plug
                    ;~(pose parse-qualified-object parse-alias)
                    ;~(pfix whitespace ;~(pfix (jester 'as') parse-alias))
                    ==
                  ==
        ;~  plug  (cold %using ;~(plug whitespace (jester 'using') whitespace))
                  %:  stag  %query-row
                            ;~  plug  face-list
                                      ;~  pfix
                                        whitespace
                                        ;~(pfix (jester 'as') parse-alias)
                                        ==
                                      ==
                            ==
                  ==
        ;~  plug  (cold %using ;~(plug whitespace (jester 'using') whitespace))
                  ;~  plug  ;~(pose parse-qualified-object parse-alias)
                            (cold %as whitespace)
                            ;~(less merge-stop parse-alias)
                            ==
                  ==
        ;~  plug  (cold %using ;~(plug whitespace (jester 'using') whitespace))
                   %:  stag  %query-row
                            ;~  plug  face-list
                                      ;~  pfix
                                        whitespace
                                        ;~(less merge-stop parse-alias)
                                        ==
                                      ==
                            ==
                  ==
        ;~  plug  (cold %using ;~(plug whitespace (jester 'using') whitespace))
                  parse-qualified-object
                  ==
        ;~  plug  (cold %using ;~(plug whitespace (jester 'using') whitespace))
                  (stag %query-row face-list)
                  ==
    ==
    ;~(plug ;~(pfix whitespace (jester 'on')) parse-predicate)
    ;~(pfix whitespace (star parse-merge-when))
    (easy ~)
  ==
++  merge-stop  ~+
  ;~  pose
    ;~(plug (jester 'with') whitespace)
    ;~(plug (jester 'using') whitespace)
    ;~(plug (jester 'on') whitespace)
    ;~(plug (jester 'when') whitespace)
  ==
++  update-column-inner  ~+
  ;~  pose
  ;~  plug
    sym
    ;~  pfix
      whitespace
      ;~  pfix
        (jest '=')
        ;~(pfix whitespace ;~(pose parse-qualified-column parse-value-literal))
        ==
      ==
    ==
  ==
++  update-column  ~+
  ;~  pose
    ;~(pfix whitespace ;~(sfix update-column-inner whitespace))
    ;~(pfix whitespace update-column-inner)
    ;~(sfix update-column-inner whitespace)
    update-column-inner
  ==
++  parse-update  ~+
  ;~  pose
    ;~  plug
      ;~(pfix whitespace parse-qualified-object)
      parse-as-of
      (cold %set ;~(plug whitespace (jester 'set')))
      (more com update-column)
      ;~  pose
        ;~(pfix ;~(plug whitespace (jester 'where')) parse-predicate)
        (easy ~)
        ==
    ==
    ;~  plug
      ;~(pfix whitespace parse-qualified-object)
      (cold %set ;~(plug whitespace (jester 'set')))
      (more com update-column)
      ;~  pose
        ;~(pfix ;~(plug whitespace (jester 'where')) parse-predicate)
        (easy ~)
        ==
    ==
  ==
++  parse-with  ~+
  ;~  plug
    parse-ctes
    ;~  pose
      ;~  plug
        (cold %delete ;~(plug (jester 'delete') whitespace (jester 'from')))
        parse-delete
        ==
      ;~(plug (jester 'delete') parse-delete)
      ;~  plug
        (cold %insert ;~(plug (jester 'insert') whitespace (jester 'into')))
        parse-insert
        ==
      ;~  plug
        (cold %merge ;~(plug (jester 'merge') whitespace (jester 'into')))
        parse-merge
        ==
      ;~  plug
        (cold %merge ;~(plug (jester 'merge') whitespace (jester 'from')))
        parse-merge
        ==
      ;~(plug (jester 'merge') parse-merge)
      ;~(plug (cold %query ;~(plug (jester 'from'))) parse-query)
      ;~  plug
          %:  cold
            %query
            ;~(plug ;~(pfix (jester 'select') (funk "select" (easy ' '))))
            ==
          parse-query
          ==
      ;~(plug (jester 'update') parse-update)
      ==
  ==
++  with-stop  ~+
  ;~  pose
    ;~(plug (jester 'delete') whitespace)
    ;~(plug (jester 'insert') whitespace)
    ;~(plug (jester 'merge') whitespace)
    ;~(plug (jester 'query') whitespace)
    ;~(plug (jester 'select') whitespace)
    ;~(plug (jester 'update') whitespace)
  ==
++  parse-cte  ~+
  ;~  plug
    (cold %cte ;~(plug whitespace (jest '(')))
    ;~  pose
      ;~(pfix ;~(whitespace (jester 'from')) parse-query)
      ;~(pfix (jester 'from') parse-query)
      parse-query
    ==
    ;~  pose
      ;~(pfix whitespace ;~(pfix (jest ')') ;~(pfix whitespace (jester 'as'))))
      ;~(pfix (jest ')') ;~(pfix whitespace (jester 'as')))
      ==
    ;~(pose ;~(sfix parse-alias whitespace) parse-alias)
  ==
++  parse-ctes  ~+
  (more com ;~(pose with-stop parse-cte))
++  parse-revoke  ~+
  ;~  plug
    :: permission
    ;~  pfix
      whitespace
      ;~  pose  (jester 'adminread')
                (jester 'readonly')
                (jester 'readwrite')
                (jester 'all')
                ==
      ==
    :: revokees
    ;~  pfix
          whitespace
          ;~  pfix  (jester 'from')
                    ;~  pose  ;~  plug
                                  ;~  plug
                                        ;~  pfix  whitespace
                                                    (stag ~.tas (jester 'all'))
                                                    ==
                                            (easy ~)
                                            ==
                                        (easy ~)
                                        ==
                              parse-ship-paths
                              ==
                    ==
          ==
    :: revoke-objects
    parse-revoke-objects
    ;~(sfix parse-grant-duration end-or-next-command)
  ==
++  parse-revoke-objects
  ;~  pfix
    whitespace
    ;~  pfix
      (jester 'on')
      %+  more  com  
                ;~  pose  ;~  pfix  whitespace
                                    ;~(sfix parse-revoke-object whitespace)
                                    ==
                          ;~(pfix whitespace parse-revoke-object)
                          ;~(sfix parse-revoke-object whitespace)
                          parse-revoke-object
                          ==
    ==
  ==
++  parse-revoke-object
  ;~  pose  (jester 'all')
            (jester 'server')
            on-database
            on-namespace
            (stag %table-column stap)
            (stag %table-set parse-qualified-3object)
            ==
++  parse-truncate-table  ~+
  ;~  sfix
    ;~  pfix
          whitespace
          ;~  pose
              ;~(plug parse-qualified-object parse-as-of)
              parse-qualified-object
          ==
    ==
    end-or-next-command
  ==
::
::  parse productions
::
++  produce-ctes
  |=  a=*
  ^-  (list cte:ast)
  =/  ctes=(list cte:ast)  ~
  |-
  ?~  a  (flop ctes)
  ?:  ?&(=(%cte -<.a) =(%as ->+<.a))
    %=  $
      a  +.a
      ctes  [(cte:ast %cte ->+>.a (produce-query ->-.a)) ctes]
    ==
  ~|('cannot produce ctes from parsed:  {<a>}' !!)
++  produce-delete
  |=  a=*
   ~+
  ^-  delete:ast
  ?>  ?=(qualified-object:ast -.a)
  ?:  ?=([* %where * %end-command ~] a)
    %:  delete:ast  %delete
                    -.a
                    ~
                    %+  qualify-predicate
                        (produce-predicate (predicate-list +>-.a))
                        -.a
                    ==
  ?:  ?=([* [%as-of %now] %where * %end-command ~] a)
    %:  delete:ast  %delete
                    -.a
                    ~
                    %+  qualify-predicate
                        (produce-predicate (predicate-list +>+<.a))
                        -.a
                    ==
  ?:  ?=([* [%as-of [@ @]] %where * %end-command ~] a)
    %:  delete:ast  %delete
                    -.a
                    [~ +<+.a]
                    %+  qualify-predicate
                        (produce-predicate (predicate-list +>+<.a))
                        -.a
                    ==
  ?:  ?=([* [%as-of *] %where * %end-command ~] a)
    %:  delete:ast  %delete
                    -.a
                    [~ (as-of-offset:ast %as-of-offset +<+<.a +<+>-.a)]
                    %+  qualify-predicate
                        (produce-predicate (predicate-list +>+<.a))
                        -.a
                    ==
  !!
::
++  qualify-predicate
  |=  [p=predicate:ast obj=qualified-object:ast]
  ^-  predicate:ast
  ::
  |-
  ?~  p  ~
  p(n (qualify-pred-leaf n.p obj), l $(p l.p), r $(p r.p))
::
++  qualify-pred-leaf
  |=  [a=predicate-component:ast obj=qualified-object:ast]
  ^-  predicate-component:ast
  ?.  ?&  ?=(qualified-column:ast a)
          =('UNKNOWN' database.qualifier.a)
          =('COLUMN-OR-CTE' namespace.qualifier.a)
          ==
    a
  %:  qualified-column:ast  %qualified-column
                            obj
                            column.a
                            alias.a
                            ==
::
++  produce-insert
  |=  a=*
  ~+
  ^-  insert:ast
  =/  table  -<.a
  =/  c      ->.a
  ::
  ?:  ?=([[%as-of %now] %values *] c)  :: insert rows as of now
    %:  insert:ast  %insert
                     table
                     ~
                     ~
                     (insert-values:ast %data +>.c)
                     ==
  ?:  ?=([[%as-of @ @] %values *] c)  :: insert rows as of date
    %:  insert:ast  %insert
                    table
                    [~ ->.c]
                    ~
                    (insert-values:ast %data +>.c)
                    ==
  ?:  ?=([[%as-of @ @ @] %values *] c)  :: insert rows as of offset
    %:  insert:ast  %insert
                    table
                    [~ (as-of-offset:ast %as-of-offset ->-.c ->+<.c)]
                    ~
                    (insert-values:ast %data +>.c)
                    ==
  ?:  ?=([[%as-of %now] [* %values] *] c) :: insert columns rows as of now
    %:  insert:ast  %insert
                    table
                    ~
                    `+<-.c
                    (insert-values:ast %data +>.c)
                    ==
  ?:  ?=([[%as-of @ @] [* %values] *] c) :: insert cols rows as of date
     %:  insert:ast  %insert
                    table
                    [~ ->.c]
                    `+<-.c
                    (insert-values:ast %data +>.c)
                    ==
  ?:  ?=([[%as-of @ @ @] [* %values] *] c) :: insert cols rows as of offset
     %:  insert:ast  %insert
                    table
                    [~ (as-of-offset:ast %as-of-offset ->-.c ->+<.c)]
                    `+<-.c
                    (insert-values:ast %data +>.c)
                    ==
  ?:  ?=([%values *] c)            :: insert rows
    %:  insert:ast  %insert
                    table
                    ~
                    ~
                    (insert-values:ast %data +.c)
                    ==
  ?:  ?=([[* %values] *] c)        :: insert column names rows
    %:  insert:ast  %insert
                    table
                    ~
                    `-<.c
                    (insert-values:ast %data +.c)
                    ==
  ~|("Cannot parse insert {<a>}" !!)
++  produce-matching-profile
  |=  a=*
  ^-  (list [@t datum:ast])
  =/  profile=(list [@t datum:ast])  ~
  |-
  ?~  a  (flop profile)
  ?:  ?=([@ %qualified-column qualified-object:ast @ ~] -.a)
    %=  $
      profile  :-  :-  -<.a
                      %:  qualified-column:ast  %qualified-column
                                                `qualified-object:ast`->+<.a
                                                ->+>-.a
                                                ~
                                                ==
                   profile
      a  +.a
    ==
  ?:  =(%values ->.a)
    ?:  =(~ -<.a)
      ?:  =(~ +<.a)  $(a ~)
        ~|("produce-matching-profile error:  {<a>}" !!)
    ?@  -<-.a
      ?:  ?=(datum:ast +<-.a)
        %=  $
         profile  [[-<-.a +<-.a] profile]
          a  [[-<+.a 'values'] +<+.a ~]
        ==
      ~|("produce-matching-profile error on source:  {<+<-.a>}" !!)
    ~|("produce-matching-profile error:  {<a>}" !!)
  ~|("produce-matching-profile error:  {<a>}" !!)
++  produce-matching
  |=  a=*
  ^-  [(list matching:ast) (list matching:ast) (list matching:ast)]
  =/  matched=(list matching:ast)  ~
  =/  not-matched-by-target=(list matching:ast)  ~
  =/  not-matched-by-source=(list matching:ast)  ~
  |-
  ?~  a
    [(flop matched) (flop not-matched-by-target) (flop not-matched-by-source)]
  ?>  ?=(matching-action:ast ->-.a)
  ?-  `matching-action:ast`->-.a
    %insert
      ?:  ?=([%matched @ *] -.a)
        %=  $
          matched
            :-  %:  matching:ast  %matching
                                  predicate=~
                      matching-profile=[->-.a (produce-matching-profile ->+.a)]
                                  ==
                matched
          a  +.a
        ==
      ?:  =(%unmatch-target -<.a)
        %=  $
          not-matched-by-target
            :-  %:  matching:ast  %matching
                                  predicate=~
                      matching-profile=[->-.a (produce-matching-profile ->+.a)]
                                  ==
                not-matched-by-target
          a  +.a
        ==
      ?:  ?&(=(%matched -<-.a) =(%predicate -<+<.a))
        %=  $
          matched
            :-  %:  matching:ast  %matching
                      predicate=`(produce-predicate (predicate-list -<+>.a))
                      matching-profile=[->-.a (produce-matching-profile ->+.a)]
                                  ==
                matched
          a  +.a
        ==
      ~|("merge insert can't get here:  {<-.a>}" !!)
    %update
      ?:  ?=([%matched @ *] -.a)
        %=  $
          matched
            :-  %:  matching:ast  %matching
                                  predicate=~
                      matching-profile=[->-.a (produce-matching-profile ->+.a)]
                                  ==
                matched
          a  +.a
        ==
      ?:  ?&(=(%matched -<-.a) =(%predicate -<+<.a))
        %=  $
          matched
            :-  %:  matching:ast  %matching
                      predicate=`(produce-predicate (predicate-list -<+>.a))
                      matching-profile=[->-.a (produce-matching-profile ->+.a)]
                                  ==
                      matched
          a  +.a
        ==
      ~|("merge update can't get here:  {<-.a>}" !!)
    %delete
      ?:  ?=([%matched @ *] -.a)
        %=  $
          matched
            :-  %:  matching:ast  %matching
                                  predicate=~
                                  matching-profile=%delete
                                  ==
                matched
          a  +.a
        ==
      ?:  =(%unmatch-target -<.a)
        %=  $
          not-matched-by-target
            :-  %:  matching:ast  %matching
                                  predicate=~
                                  matching-profile=%delete
                                  ==
                not-matched-by-target
          a  +.a
        ==
      ?:  ?&(=(%matched -<-.a) =(%predicate -<+<.a))
        %=  $
          matched
            :-  %:  matching:ast  %matching
                                  `(produce-predicate (predicate-list -<+>.a))
                                  matching-profile=%delete
                                  ==
                matched
          a  +.a
        ==
      ~|("merge delete can't get here:  {<-.a>}" !!)
  ==
++  produce-merge
  |=  a=*
  ^-  merge:ast
  =/  into=?  %.y
  =/  target-table=(unit table-set:ast)  ~
  =/  new-table=(unit table-set:ast)  ~
  =/  source-table=(unit table-set:ast)  ~
  =/  predicate=(unit predicate:ast)  ~
  =/  matching=matching-lists:ast  [~ ~ ~]
  |-
  ?~  a  ?:  ?&(=(target-table ~) =(source-table ~))
    ~|("target and source tables cannot both be pass through" !!)
  %:  merge:ast  %merge
                (need target-table)
                new-table
                (need source-table)
                (need predicate)
                matched=matched.matching
                unmatched-by-target=not-target.matching
                unmatched-by-source=not-source.matching
                ~
                ==
  ?:  ?=(qualified-object:ast -.a)
    %=  $
      a  +.a
      target-table  `(table-set:ast %table-set -.a)
    ==
  ?:  ?=([%using @ %as @] -.a)
    %=  $
      a  +.a
      source-table
        :-  ~  %:  table-set:ast  %table-set
                                  %:  qualified-object:ast  %qualified-object
                                                            ~
                                                            default-database
                                                            'dbo'
                                                            +<.a
                                                            ==
                                   `+>+.a
                                   ==
    ==
  ?:  ?=([qualified-object:ast @] -.a)
    %=  $
      a  +.a
      target-table  `(make-query-object -.a)
    ==
  ?:  ?=([%using qualified-object:ast %as @] -.a)
    %=  $
      a  +.a
      source-table  `(table-set:ast %table-set ->-.a `->+>.a)
    ==
  ?:  =(%on -<.a)
    %=  $
      a  +.a
      predicate  `(produce-predicate (predicate-list ->.a))
    ==
  ?:  =(%query-row -<.a)
    %=  $
      a  +.a
      target-table  `(make-query-object -.a)
    ==
  ?:  =(%using -<.a)
    %=  $
      a  +.a
      source-table  `(make-query-object ->.a)
    ==
  ?:  =(%query-row -<-.a)
    %=  $
      a  +.a
      target-table  `(make-query-object -.a)
    ==
  %=  $
    a  +.a
    matching  (produce-matching -.a)
  ==
::
++  produce-query
  |=  a=*
  ~+
  ^-  query:ast     
  =/  from=(unit from:ast)  ~
  =/  scalars=(list scalar-function:ast)  ~
  =/  predicate=(unit predicate:ast)  ~
  =/  group-by=(list grouping-column:ast)  ~
  =/  having=(unit predicate:ast)  ~
  =/  select=(unit select:ast)  ~
  =/  order-by=(list ordering-column:ast)  ~
  =/  alias-map=(map @t qualified-object:ast)  ~
  |-
  ?~  a  ~|("cannot parse query  {<a>}" !!)

  =.  alias-map  ?~   alias-map
                   ?~   from  ~
                   (mk-alias-map (need from))
                 alias-map 

  ?:  =(-.a %query)           $(a +.a)
  ?:  =(-.a %end-command)    %:  query:ast
                                %query
                                ?~  from  ~
                                  `(fix-from-predicates (need from) alias-map)
                                scalars
                                ?~  predicate  ~
                                  `(fix-predicate (need predicate) alias-map)
                                group-by
                                having
                                (need select)
                                order-by
                                ==
  ?:  =(-<.a %scalars)        $(a +.a, scalars ~)
  ?:  =(-<.a %where)          %=  $
                                a          +.a
                                predicate  :-  ~
                                               %-  produce-predicate
                                                   (predicate-list ->.a)
                              ==
  ?:  =(-<.a %select)     $(a +.a, select `(produce-select ->.a from alias-map))
  ?:  =(-<.a %group-by)     $(a +.a, group-by (group-by-list ->.a))
  ?:  =(-<.a %order-by)     $(a +.a, order-by (order-by-list ->.a))
  ?:  =(-<-.a %table-set)   $(a +.a, from `(produce-from -.a))
  ?:  =(-<-.a %query-row)   $(a +.a, from `(produce-from -.a))
  ?:  =(-<-<.a %table-set)  $(a +.a, from `(produce-from -.a))
  ~|("cannot parse query  {<a>}" !!)
::
++  produce-from
  |=  a=*
  ^-  from:ast
  =/  from-object=table-set:ast
        ?:  ?=([%table-set %qualified-object (unit @p) @ @ @ (unit @t)] -<.a)
          :-  %table-set
              %:  qualified-object:ast  %qualified-object
                                        -<+>-.a
                                        -<+>+<.a
                                        -<+>+>-.a
                                        -<+>+>+<.a
                                        -<+>+>+>.a
                                        ==
        `table-set:ast`(make-query-object ->.a)
  =/  from-as-of=(unit as-of:ast)
        ?:  =(%as-of-offset ->-.a)  [~ ;;(as-of-offset:ast ->.a)]
        ?:  =(~.da ->-.a)           [~ ;;(as-of:ast [%da ->+.a])]
        ?:  =(~.dr ->-.a)           [~ ;;(as-of:ast [%dr ->+.a])]
        ~
  =/  raw-joined-objects  +.a
  =/  joined-objects=(list joined-object:ast)  ~
  |-
  ?:  =(raw-joined-objects ~)
    (from:ast %from from-object from-as-of (flop joined-objects))
  =/  raw-join  -.raw-joined-objects
  ::cross join
  ?:  ?=  $:  %cross-join
              [%table-set [%qualified-object (unit @p) @ @ @ (unit @t)]]
              ==
          raw-join
      %=  $
        joined-objects
          :-  %:  joined-object:ast  %joined-object
                                     %cross-join
                                     +.raw-join
                                     ~
                                     ~
                                     ==
              joined-objects
        raw-joined-objects  +.raw-joined-objects
      ==
  ?:  ?=  $:  %cross-join
              [%table-set [%qualified-object (unit @p) @ @ @ (unit @t)]]
              %as-of-offset
              *
              ==
          raw-join
      %=  $
        joined-objects
          :-  %:  joined-object:ast  %joined-object
                                     %cross-join
                                     +<.raw-join
                                     `+>.raw-join
                                     ~
                                     ==
              joined-objects
        raw-joined-objects  +.raw-joined-objects
      ==
  ?:  ?|  ?=  $:  %cross-join
                  [%table-set [%qualified-object (unit @p) @ @ @ (unit @t)]]
                  [%da @]
                  ==
              raw-join
          ?=  $:  %cross-join
                  [%table-set [%qualified-object (unit @p) @ @ @ (unit @t)]]
                  [%dr @]
                  ==
              raw-join
          ==
      %=  $
        joined-objects
          :-  %:  joined-object:ast  %joined-object
                                     %cross-join
                                     +<.raw-join
                                     `;;(as-of:ast [+>-.raw-join +>+.raw-join])
                                     ~
                                     ==
              joined-objects
        raw-joined-objects  +.raw-joined-objects
      ==
  ::natural join
  ?:  ?|  ?=  [%join [%table-set [%qualified-object (unit @p) @ @ @ (unit @t)]]]
              raw-join
          ?=  $:  %join
                  $:  [%table-set [%qualified-object (unit @p) @ @ @ (unit @t)]]
                      %as-of-offset
                      *
                      ==
                  ==
              raw-join
          ?=  $:  %join
                  $:  [%table-set [%qualified-object (unit @p) @ @ @ (unit @t)]]
                      [%da @]
                      ==
                  ==
              raw-join
          ?=  $:  %join
                  $:  [%table-set [%qualified-object (unit @p) @ @ @ (unit @t)]]
                      [%dr @]
                      ==
                  ==
              raw-join
          ==
    %=  $
      joined-objects
        :-
          %:  joined-object:ast
            %joined-object
            %join
            ::  object
            ?:  ?=  $:  %join
                        $:  %table-set
                            [%qualified-object (unit @p) @ @ @ (unit @t)]
                            ==
                        ==
                    raw-join
              (make-query-object +>.raw-join)
            (make-query-object +<+.raw-join)
            :: as-of
            ?:  ?=  $:  $:  %table-set
                            [%qualified-object (unit @p) @ @ @ (unit @t)]
                            ==
                        %as-of-offset
                        *
                        ==
                    +.raw-join
              [~ ;;(as-of-offset:ast +>.raw-join)]
            ?:  ?=  $:  $:  %table-set
                            [%qualified-object (unit @p) @ @ @ (unit @t)]
                            ==
                        [@ @]
                        ==
                    +.raw-join
              [~ ;;(as-of:ast +>.raw-join)]
            ~
            ~  :: predicate
          ==
          joined-objects
      raw-joined-objects    +.raw-joined-objects
    ==

  :: join on predicate (no alias)
  ?:  ?=(join-type:ast -.raw-join)
    ?:  ?|  ?=  $:  [%table-set [%qualified-object (unit @p) @ @ @ (unit @t)]]
                    %as-of-offset
                    @
                    @
                    ==
                +<.raw-join
            ?=  $:  [%table-set [%qualified-object (unit @p) @ @ @ (unit @t)]]
                    [%da @]
                    ==
                +<.raw-join
            ?=  $:  [%table-set [%qualified-object (unit @p) @ @ @ (unit @t)]]
                    [%dr @]
                    ==
                +<.raw-join
            ==
      %=  $
        joined-objects
          :-
            %:  joined-object:ast
              %joined-object
              :: join-type
              -.raw-join
              ::  object
              +<-.raw-join
              :: as-of
              ?:  ?=  [%as-of-offset *]
                      +<+.raw-join
                [~ +<+.raw-join]
              ?:  ?=  [@ @]
                      +<+.raw-join
                [~ ;;(as-of:ast +<+.raw-join)]
              ~
              :: predicate
            `(produce-predicate (predicate-list +>.raw-join))
            ==
            joined-objects
        raw-joined-objects    +.raw-joined-objects
      ==
    ?:  ?=  [[%table-set [%qualified-object (unit @p) @ @ @ (unit @t)]] *]
            +.raw-join
      %=  $
        joined-objects
          :-
            %:  joined-object:ast
              %joined-object
              :: join-type
              -.raw-join
              ::  object
              +<.raw-join
              :: as-of
              ~
              :: predicate
            `(produce-predicate (predicate-list +>.raw-join))
            ==
            joined-objects
        raw-joined-objects    +.raw-joined-objects
      ==
    ~|("join not supported: {<raw-join>}" !!)
  ~|("join type not supported: {<-.raw-join>}" !!)
::
++  fix-from-predicates
  |=  [f=from:ast alias-map=(map @t qualified-object:ast)]
  ^-  from:ast
  =/  jss  joins.f
  =/  js=(list joined-object:ast)  ~
  |-
  ?~  jss
    (from:ast %from object.f as-of.f (flop js))
  =/  j=joined-object:ast  -.jss
  %=  $
    js   :-  ?~  predicate.j  j
             %:  joined-object:ast
                   %joined-object
                   join.j
                   object.j
                   as-of.j
                   `(fix-predicate (need predicate.j) alias-map)
                   ==
             js
    jss  +.jss
  ==
::
++  fix-predicate
  |=  [p=predicate:ast alias-map=(map @t qualified-object:ast)]
  ^-  predicate:ast
  ::
  |-
  ?~  p  ~
  p(n (fix-leaf n.p alias-map), l $(p l.p), r $(p r.p))
::
++  fix-leaf
  |=  [a=predicate-component:ast alias-map=(map @t qualified-object:ast)]
  ^-  predicate-component:ast
  ?-  a
    ops-and-conjs:ast
      a
    qualified-column:ast
      ?:  ?&  =('UNKNOWN' database.qualifier.a)
              =('COLUMN-OR-CTE' namespace.qualifier.a)
              ==
        %^  unqualified-column:ast  %unqualified-column
                                    column.a
                                    alias.a
      ?:  ?&  =('UNKNOWN' database.qualifier.a)
              =('COLUMN' namespace.qualifier.a)
              ==
        %:  qualified-column:ast  %qualified-column
                                  %-  ~(got by alias-map)
                                      (crip (cass (trip name.qualifier.a)))
                                  column.a
                                  alias.a
                                  ==
      a
    unqualified-column:ast
      a
    dime:ast
      a
    value-literals:ast
      a
    aggregate:ast
      a
    ==
::
::
++  mk-all-object
  |=  [=qualified-column:ast alias-map=(map @t qualified-object:ast)]
  ^-  selected-all-object:ast
  =/  object  %-  ~(get by alias-map)
                  (crip (cass (trip name.qualifier.qualified-column)))
  ?~  object
    %+  selected-all-object:ast  %all-object
                                 %:  qualified-object:ast
                                      %qualified-object
                                      ~ 
                                      default-database
                                      %dbo
                                      name.qualifier.qualified-column
                                      ==
  (selected-all-object:ast %all-object (need object))
::
++  mk-qualified-object
  |=  [sel-col=qualified-column:ast alias-map=(map @t qualified-object:ast)]
  ^-  qualified-column:ast
  =/  object  %-  ~(get by alias-map)
                  (crip (cass (trip name.qualifier.sel-col)))
  ?~  object
    %:  qualified-column:ast  %qualified-column
                              %:  qualified-object:ast
                                  %qualified-object
                                  ship.qualifier.sel-col
                                  default-database
                                  %dbo
                                  name.qualifier.sel-col
                                  alias.qualifier.sel-col
                                  ==
                              column.sel-col
                              alias.sel-col
                              ==
  %:  qualified-column:ast
      %qualified-column
      (need object)
      column.sel-col
      alias.sel-col
      ==
::
++  fix-select
  |=  [s=(list selected-column:ast) alias-map=(map @t qualified-object:ast)]
  ^-  (list selected-column:ast)
  =/  s-out=(list selected-column:ast)  ~
  ::
  |-
  ?~  s  (flop s-out)
  =/  sel-col=selected-column:ast  -.s
  %=  $
    s      +.s
    s-out  :-  ?.  ?=(qualified-column:ast sel-col)
                 sel-col
               ?:  ?&  =('UNKNOWN' database.qualifier.sel-col)
                       =('COLUMN' namespace.qualifier.sel-col)
                       ==
                  (mk-qualified-object sel-col alias-map)
               ?:  ?&  =('UNKNOWN' database.qualifier.sel-col)
                       =('COLUMN-OR-CTE' namespace.qualifier.sel-col)
                       =('ALL' column.sel-col)
                       ==
                  (mk-all-object sel-col alias-map) 
               ?:  ?&  =('ALL' column.sel-col)
                       !=(name.qualifier.sel-col column.sel-col)
                       ==
                  %+  selected-all-object:ast
                      %all-object
                      qualifier.sel-col
               ?:  ?&  =('UNKNOWN' database.qualifier.sel-col)
                       =('COLUMN-OR-CTE' namespace.qualifier.sel-col)
                       ==
                  %^  unqualified-column:ast  %unqualified-column
                                              column.sel-col
                                              alias.sel-col
               sel-col
               ::
               s-out
  ==
::
::  +mk-alias-map:  from:ast -> (map @t qualified-object:ast)
::
:: map table-set alias to qualified-object
:: if db of qualified-object is default db
:: and namespace is 'dbo'
::
++  mk-alias-map
  |=  f=from:ast
  ^-  (map @t qualified-object:ast)
  =/  n  (mk-alias-map-joins ~ joins.f)
  ?.  ?=(qualified-object:ast object.object.f)
    ~|("not implemented {<object.f>}" !!)
  ?~  alias.object.object.f
    n
  %+  ~(put by n)  (crip (cass (trip (need alias.object.object.f))))
                   object.object.f
::
++  mk-alias-map-joins
  |=  [m=(map @t qualified-object:ast) js=(list joined-object:ast)]
  ^-  (map @t qualified-object:ast)
  |-
  ?~  js  m
  =/  j=joined-object:ast  -.js
  ?.  ?=(qualified-object:ast object.object.j)
    ~|("not implemented {<object.j>}" !!)
  %=  $
    m   ?~  alias.object.object.j  m
        %+  ~(put by m)  (crip (cass (trip (need alias.object.object.j))))
                         object.object.j
    js  +.js
  ==
::
::  +mk-obj-name-map:  from:ast -> (map @t qualified-object:ast)
::
:: map table-set object name to qualified-object
:: if db of qualified-object is default db
:: and namespace is 'dbo'
::
++  mk-obj-name-map
  |=  f=from:ast
  ^-  (map @t qualified-object:ast)
  =/  n  (mk-obj-name-map-joins ~ joins.f)
  ?.  ?=(qualified-object:ast object.object.f)
    ~|("not implemented {<object.f>}" !!)
  %+  ~(put by n)  (crip (cass (trip name.object.object.f)))
                   object.object.f
::
++  mk-obj-name-map-joins
  |=  [m=(map @t qualified-object:ast) js=(list joined-object:ast)]
  ^-  (map @t qualified-object:ast)
  |-
  ?~  js  m
  =/  j=joined-object:ast  -.js
  ?.  ?=(qualified-object:ast object.object.j)
    ~|("not implemented {<object.j>}" !!)
  %=  $
    m   %+  ~(put by m)  (crip (cass (trip name.object.object.j)))
                         object.object.j
    js  +.js
  ==
+$  select-mold-1
  $:
    $:  %selected-aggregate
        @
        %qualified-column
        [%qualified-object (unit @p) @ @ @ (unit @t)]
        @
        @
        ==
    %as
    @
  ==
+$  select-mold-2
  $:
    $:  %selected-aggregate
        @
        %qualified-column
        [%qualified-object (unit @p) @ @ @ (unit @t)]
        @
        @
        ==
  ==
++  produce-select
  |=  [a=* f=(unit from:ast) alias-map=(map @t qualified-object:ast)]
  ^-  select:ast
  =/  top=(unit @ud)  ~
  =/  bottom=(unit @ud)  ~
  =/  columns=(list selected-column:ast)  ~
  |-
    ~|  "cannot parse select -.a:  {<-.a>}"
    ?~  a
      ?~  columns  ~|('no columns selected' !!)
      ?~  f
        (select:ast %select top bottom (flop columns))
      (select:ast %select top bottom (fix-select (flop columns) alias-map))
    ?@  -.a
      ?+  -.a  ~|('some other select atom' !!)
      %top       ?>  ?=(@ud +<.a)  $(top `+<.a, a +>.a)
      %bottom    ?>  ?=(@ud +<.a)  $(bottom `+<.a, a +>.a)
      %all
        %=  $
          columns
            :-  (selected-all:ast %all %all)
                columns
          a        +.a
        ==
      ==
    ?:  ?=(select-mold-1 -.a)
      %=  $
        columns
          :-  %:  selected-aggregate:ast
                %selected-aggregate
                %:  aggregate:ast  %aggregate
                                  (aggregate-name -<+<.a)
                                  %:  qualified-column:ast  %qualified-column
                                                            -<+>+<.a
                                                            -<+>+>-.a
                                                            -<+>+>+.a
                                                            ==
                                  ==
                `->+.a
              ==
              columns
        a        +.a
      ==
    ?:  ?=(select-mold-2 -.a)
      %=  $
        columns
          :-  %:  selected-aggregate:ast
                %selected-aggregate
                %:  aggregate:ast  %aggregate
                                  (aggregate-name ->-.a)
                                  %:  qualified-column:ast  %qualified-column
                                                            ->+>-.a
                                                            ->+>+<.a
                                                            ->+>+>.a
                                                            ==
                                  ==
                ~
              ==
          columns
        a        +.a
      ==
    ?:  ?=([%all-columns %qualified-object (unit @p) @ @ @ (unit @t)] -.a)
      %=  $
        columns
          :-  %+  selected-all-object:ast
                    %all-object
                    %:  qualified-object:ast  %qualified-object
                                              ?~  ->+<.a  ~
                                              [~ ->+<.a]
                                              ->+>-.a
                                              ->+>+<.a
                                              ->+>+>-.a
                                              ~
                                              ==
              columns
        a        +.a
      ==
    ?:  ?=([@ @] -.a)
      ?:  ?=([%all-columns @] -.a)
        %=  $
          columns  :-  %+  selected-all-object:ast
                             %all-object
                             ?:  (~(has by alias-map) (crip (cass (trip ->.a))))
                               (~(got by alias-map) (crip (cass (trip ->.a))))
                             :: to do: if does not resolve try CTEs next
                             ~|  "cannot resolve {<->.a>}"
                                 %-  ~(got by (mk-obj-name-map (need f)))
                                     ->.a
                       columns
          a        +.a
        ==
      ?>  ?=(dime -.a)
        %=  $
          columns
            [(selected-value:ast %selected-value -.a ~) columns]
          a        +.a
        ==
    ?:  ?=([qualified-column:ast %as @] -.a)
      %=  $
        columns
          :-  %:  qualified-column:ast
                %qualified-column
                %:  qualified-object:ast
                  %qualified-object
                  -<+<+<.a
                  -<+<+>-.a
                  -<+<+>+<.a
                  -<+<+>+>.a
                ==
                -<+>-.a
                `->+.a
              ==
              columns
        a        +.a
      ==
    ?:  ?=([[@tas @] %as @] -.a)
      %=  $
        columns
          :-  %:  selected-value:ast
                %selected-value
                -<.a
                `(crip (cass (trip ->+.a)))
              ==
              columns
        a        +.a
      ==
    ?>  ?=(qualified-column:ast -.a)  $(columns [-.a columns], a +.a)
++  produce-update
  |=  a=*
  ~+
  ^-  update:ast
  =/  table=qualified-object:ast  ?>(?=(qualified-object:ast -.a) -.a)
  =/  b  +.a
  ?:  ?=([%set * ~] b)
    %:  update:ast  %update
                    table
                    ~
                    (produce-column-sets table +<.b)
                    ~
                    ==
  ?:  ?=([[%as-of %now] %set * ~] b)
    %:  update:ast  %update
                    table
                    ~
                    (produce-column-sets table +>-.b)
                    ~
                    ==
  ?:  ?=([[%as-of @ @] %set * ~] b)
    %:  update:ast  %update
                    table
                    [~ ->.b]
                    (produce-column-sets table +>-.b)
                    ~
                    ==
  ?:  ?=([[%as-of *] %set * ~] b)
    %:  update:ast  %update
                    table
                    [~ (as-of-offset:ast %as-of-offset ->-.b ->+<.b)]
                    (produce-column-sets table +>-.b)
                    ~
                    ==                    
  ?:  ?=([[%as-of %now] %set * *] b)
    %:  update:ast  %update
                    table
                    ~
                    (produce-column-sets table +>-.b)
                    :-  ~
                        %+  qualify-predicate
                            (produce-predicate (predicate-list +>+.b))
                            table
                    ==
  ?:  ?=([[%as-of @ @] %set * *] b)
    %:  update:ast  %update
                    table
                    [~ ->.b]
                    (produce-column-sets table +>-.b)
                    :-  ~
                        %+  qualify-predicate
                            (produce-predicate (predicate-list +>+.b))
                            table
                    ==
  ?:  ?=([[%as-of @ @ @] %set * *] b)
    %:  update:ast  %update
                    table
                    [~ (as-of-offset:ast %as-of-offset ->-.b ->+<.b)]
                    (produce-column-sets table +>-.b)
                    :-  ~
                        %+  qualify-predicate
                            (produce-predicate (predicate-list +>+.b))
                            table
                    ==
  %:  update:ast  %update
                  table
                  ~
                  (produce-column-sets table +<.b)
                  :-  ~
                      %+  qualify-predicate
                          (produce-predicate (predicate-list +>.b))
                          table
                  ==
::
++  produce-column-sets
  |=  [table=qualified-object:ast a=*]
  ~+
  ^-  [(list qualified-column:ast) (list datum:ast)]
  =/  columns=(list qualified-column:ast)  ~
  =/  values=(list datum:ast)  ~
  |-
  ?:  =(a ~)
    [columns values]
  =/  b  -.a
  ?:  ?&  |(?=(qualified-column:ast -.b) ?=(@tas -.b))
          ?=(datum:ast +.b)
          ==
    %=  $
      columns  ?:  ?=(qualified-column:ast -.b)
                 [-.b columns]
               :-  %:  qualified-column:ast  %qualified-column
                                             table
                                             -.b
                                             ~
                                             ==
                   columns
      values   ?.  ?=(qualified-column:ast +.b)
                 [+.b values]
               ?:  ?&  =('UNKNOWN' database.qualifier.+.b)
                      =('COLUMN-OR-CTE' namespace.qualifier.+.b)
                      ==
                 :-  (unqualified-column:ast %unqualified-column column.+.b ~)
                     values
               [+.b values]
      a        +.a
    ==
  ~|("cannot parse column setting {<a>}" !!)
::
::  helper types
::
+$  interim-key
  $:
    %interim-key
    columns=(list ordered-column:ast)
  ==
+$  parens        ?(%pal %par)
+$  raw-pred-cmpnt  ?(parens predicate-component:ast)
+$  group-by-list  (list grouping-column:ast)
+$  order-by-list  (list ordering-column:ast)
::
::  parser rules and helpers
::
++  whitespace  ~+  (star ;~(pose gah (just '\09') (just '\0d')))
++  prn-less-soz  ~+  ;~(less (just `@`39) (just `@`127) (shim 32 256))
::
::  +when: replace when:so until https://github.com/urbit/urbit/issues/6870
++  when  ~+
  ;~  plug
  %+  cook
      |=([a=@ b=?] [b a])
    ;~(plug dim:ag ;~(pose (cold | hep) (easy &)))
    ;~(pfix dot mot:ag)   ::  month
    ;~(pfix dot dip:ag)   ::  day
    ;~  pose
      ;~  pfix
        ;~(plug dot dot)
        ;~  plug
          dum:ag
          ;~(pfix dot dum:ag)
          ;~(pfix dot dum:ag)
          ;~  pose
           ;~(pfix ;~(plug dot dot) (most dot qix:ab))
            ;~(less dot (easy ~))
          ==
        ==
      ==
      ;~(less dot (easy [0 0 0 ~]))
    ==
  ==
::
::  +clip-cmnt: clip commented end of line
::
++  clip-cmnt  ~+
  |=  [p=tape q=(list @) r=(list @)]
  |-  ^-  tape
  ?~  q  p
  ?:  =(0 (mod (lent (skim r |=(a=@ (lth a i.q)))) 2))  :: prior ::s in quotes
    (scag i.q `tape`p)
  $(q t.q)
::
::  +line-cmnts: strip line comments from tape of line
::
++  line-cmnts  ~+
  |=  p=tape
  =/  a=(list @)  (fand "::" p)
  |-  ^-  tape
  ?:  =(0 (lent a))  p
  =/  b=(list @)  (fand "'" p)
  ?:  =(0 (lent b))
    ?:  =(0 -.a)  ~
    (scag -.a p)
  =/  c=(set @)   (silt (turn (fand "\\'" p) |=(a=@ +(a))))
  (clip-cmnt p a (sort ~(tap in (~(dif in (silt b)) c)) lth))
::
::  +block-cmnts: strip block comments from tape
::
::  Crash
::    comment block mismatch line <n>
::
++  block-cmnts  ~+
  |=  p=tape
  =/  a=@  0
  =/  b=tape  ~
  =/  c=(list @)  (flop (fand ~['\0a'] p))
  |-  ^-  tape
  ?~  p  b
  ?~  c
    ?:  =("::" (scag 2 `tape`p))  $(p ~)
    ?:  &(=(a 1) =("/*" (scag 2 `tape`p)))  $(p ~)
    ?:  =(0 (lent (fand "::" p)))  $(p ~, b (weld (weld p " ") b))
      %=  $
        p  ~
        b  (weld (weld (line-cmnts `tape`p) " ") b)
      ==
  ?:  =("::" (scag 2 (slag i.c `tape`p)))
    %=  $
      p  (scag i.c `tape`p)
      c  t.c
    ==
  ?:  =("*/" (scag 2 (slag (add 1 i.c) `tape`p)))
    %=  $
      p  (scag i.c `tape`p)
      a  (add a 1)
      b  ?.  =(a 0)  b
             (weld (weld (line-cmnts (slag (add 3 i.c) `tape`p)) " ") b)
      c  t.c
    ==
  ?:  =("/*" (scag 2 (slag (add 1 i.c) `tape`p)))
    %=  $
      p  (scag i.c `tape`p)
      a  ~|  "comment block mismatch line {<(lent c)>}"  (sub a 1)
      c  t.c
    ==
  ?.  =(a 0)  $(p (scag i.c `tape`p), c t.c)
  %=  $
    p  (scag i.c `tape`p)
    b  (weld (weld (line-cmnts (slag (add 1 i.c) `tape`p)) " ") b)
    c  t.c
  ==
::
::  +crub-no-text: crub:so without text parsing
++  crub-no-text  ~+
  ;~  pose
    (cook |=(det=date `dime`[%da (year det)]) when) :: when:so
    %+  cook
      |=  [a=(list [p=?(%d %h %m %s) q=@]) b=(list @)]
      =+  rop=`tarp`[0 0 0 0 b]
      |-  ^-  dime
      ?~  a
        [%dr (yule rop)]
      ?-  p.i.a
        %d  $(a t.a, d.rop (add q.i.a d.rop))
        %h  $(a t.a, h.rop (add q.i.a h.rop))
        %m  $(a t.a, m.rop (add q.i.a m.rop))
        %s  $(a t.a, s.rop (add q.i.a s.rop))
      ==
    ;~  plug
      %+  most
        dot
      ;~  pose
        ;~(pfix (just 'd') (stag %d dim:ag))
        ;~(pfix (just 'h') (stag %h dim:ag))
        ;~(pfix (just 'm') (stag %m dim:ag))
        ;~(pfix (just 's') (stag %s dim:ag))
      ==
      ;~(pose ;~(pfix ;~(plug dot dot) (most dot qix:ab)) (easy ~))
    ==
    (stag %p fed:ag)
  ==
::
::  +jester: match a cord, case agnostic, thanks ~tinnus-napbus
++  jester
  |=  daf=@t
  |=  tub=nail
  ~+
  =+  fad=daf
  |-  ^-  (like @t)
  ?:  =(`@`0 daf)
    [p=p.tub q=[~ u=[p=fad q=tub]]]
  =+  n=(end 3 daf)
  ?.  ?&  ?=(^ q.tub)
          ?|  =(n i.q.tub)
              &((lte 97 n) (gte 122 n) =((sub n 32) i.q.tub))
              &((lte 65 n) (gte 90 n) =((add 32 n) i.q.tub))
          ==
      ==
    (fail tub)
  $(p.tub (lust i.q.tub p.tub), q.tub t.q.tub, daf (rsh 3 daf))
::
::  qualified objects, usually table or view
::  maximally qualified by @p.database.namespace
::  minimally qualified by namespace
::
::  +cook-qualified-2object: namespace.object-name
++  cook-qualified-2object
  |=  a=*
  ~+
  ?@  a
    (qualified-object:ast %qualified-object ~ default-database 'dbo' a ~)
  (qualified-object:ast %qualified-object ~ default-database -.a +.a ~)
::
::  +cook-qualified-3object: database.namespace.object-name
++  cook-qualified-3object
  |=  a=*
  ~+
  ?:  ?=([@ @ @] a)                                 :: db.ns.name
    (qualified-object:ast %qualified-object ~ -.a +<.a +>.a ~)
  ?:  ?=([@ @ @ @] a)                               :: db..name
    (qualified-object:ast %qualified-object ~ -.a 'dbo' +>+.a ~)
  ?:  ?=([@ @] a)                                   :: ns.name
    (qualified-object:ast %qualified-object ~ default-database -.a +.a ~)
  ?@  a                                             :: name
    (qualified-object:ast %qualified-object ~ default-database 'dbo' a ~)
  ~|("cannot parse qualified-object  {<a>}" !!)
::
::  +cook-qualified-object: @p.database.namespace.object-name
++  cook-qualified-object
  |=  a=*
  ~+
  ?:  ?=([@ @ @ @] a)
    ?:  =(+<.a '.')
      (qualified-object:ast %qualified-object ~ -.a 'dbo' +>+.a ~)  :: db..name
    :: ~firsub.db.ns.name
    (qualified-object:ast %qualified-object `-.a +<.a +>-.a +>+.a ~)
  ?:  ?=([@ @ @ @ @ @] a)                           :: ~firsub.db..name
    (qualified-object:ast %qualified-object `-.a +>-.a 'dbo' +>+>+.a ~)
  ?:  ?=([@ @ @] a)
    (qualified-object:ast %qualified-object ~ -.a +<.a +>.a ~)  :: db.ns.name
  ?:  ?=([@ @] a)                                   :: ns.name
    (qualified-object:ast %qualified-object ~ default-database -.a +.a ~)
  ?@  a                                             :: name
    (qualified-object:ast %qualified-object ~ default-database 'dbo' a ~)
  ~|("cannot parse qualified-object  {<a>}" !!)
::  +qualified-namespace: database.namespace
++  qualified-namespace
  |=  [a=* default-database=@t]
  ~+
  ?:  ?=([@ @] [a])
    a
  [default-database a]
++  parse-qualified-2-name  ~+
  ;~(pose ;~(pfix whitespace ;~((glue dot) sym sym)) parse-face)
::
::  +parse-qualified-3: database.namespace.object-name
++  parse-qualified-3  ~+
  ;~  pose
    ;~((glue dot) sym sym sym)
    ;~(plug sym dot dot sym)
    ;~((glue dot) sym sym)
    sym
  ==
++  parse-qualified-3object  ~+
  (cook cook-qualified-3object ;~(pfix whitespace parse-qualified-3))
++  parse-qualified-object  ~+
  %:  cook  cook-qualified-object
            ;~  pose  ;~((glue dot) parse-ship sym sym sym)
                      ;~(plug parse-ship dot sym dot dot sym)
                      ;~(plug sym dot dot sym)
                      parse-qualified-3
                      ==
            ==
::
::  working with atomic value literals
::
++  cord-literal  ~+
  %:  cook  |=(a=(list @t) [%t (crip a)])
        (ifix [soq soq] (star ;~(pose (cold '\'' (jest '\\\'')) prn-less-soz)))
            ==
++  numeric-parser  ~+
  ;~  pose
    (stag %ud (full dem:ag))                      :: formatted @ud
    (stag %ud (full dim:ag))                   :: unformatted @ud, no leading 0s
    ;~(pfix dot (stag %rs (full royl-rs:so)))     :: @rs
    (full tash:so)                                :: @sd or @sx
    (stag %ub (full bay:ag))                     :: formatted @ub, no leading 0s
    (stag %ux ;~(pfix (jest '0x') (full hex:ag))) :: formatted @ux
    (stag %rd (full royl-rd:so))                  :: @rd
    (stag %uw (full wiz:ag))                   :: formatted @uw base-64 unsigned
  ==
++  non-numeric-parser  ~+
  ;~  pose
    cord-literal
    ;~(pose ;~(pfix sig crub-no-text) crub-no-text)  :: @da, @dr, @p
    (stag %f ;~(pose (cold & (jester 'y')) (cold | (jester 'n'))))  :: @if
    (stag %is ;~(pfix (just '.') bip:ag))            :: @is
    (stag %if ;~(pfix (just '.') lip:ag))            :: @if
  ==
++  cook-numbers  ~+                               :: works for insert values
  |=  a=(list @t)
  ~|("error on numeric parser {<a>} " (scan a numeric-parser))
++  sear-numbers  ~+                               :: works for predicate values
  |=  a=(list @t)
  =/  parsed  (numeric-parser [[1 1] a])      :: to do: this is inside-out
  ?~  q.parsed  ~
  (some (wonk parsed))
++  numeric-characters  ~+       ::to do:  likely source of slow parse, rewrite?
  ::  including base-64 characters
  %-  star  ;~  pose  (shim 48 57)
                      (shim 65 90)
                      (shim 97 122)
                      dot
                      fas
                      hep
                      lus
                      sig
                      tis
                      ==
++  parse-value-literal  ~+
  ;~  pose  non-numeric-parser    :: \/ to do: this is inside-out
            (sear sear-numbers numeric-characters)        :: all numeric parsers
            ==
++  insert-value  ~+
  ;~  pose
    (cold [%default %default] (jester 'default'))  :: \/ to do: inside-out
    ;~(pose non-numeric-parser (cook cook-numbers numeric-characters))
  ==
++  get-value-literal  ~+
  ;~  pose :: changing to ifix here slowed down test cases
    ;~(sfix ;~(pfix whitespace parse-value-literal) whitespace)
    ;~(pfix whitespace parse-value-literal)
    ;~(sfix parse-value-literal whitespace)
    parse-value-literal
  ==
++  cook-literal-list
  ::  1. all literal types must be the same
  ::
  ::  2. (a-co:co d) each atom to tape, weld tapes with delimiter, crip final
  ::     tape bad reason for (2): cannot ?=(expression ...) when expressions
  ::     includes a list
  ::
  |=  a=(list dime)
  ~+
  =/  literal-type=@tas  -<.a
  =/  b  a
  =/  literal-list=tape  ~
  |-
  ?:  =(b ~)
    (value-literals:ast %value-literals literal-type (crip literal-list))
  ?:  =(-<.b literal-type)
    ?:  =(literal-list ~)
      $(b +.b, literal-list (a-co:co ->.b))
    $(b +.b, literal-list (weld (weld (a-co:co ->.b) ";") literal-list))
  ~|("cannot parse literal-list  {<a>}" !!)
++  value-literal-list  ~+
  %:  cook  cook-literal-list
            ;~  pose
              ;~(pfix whitespace (ifix [pal par] (more com get-value-literal)))
              (ifix [pal par] (more com get-value-literal))
              ==
            ==
++  parse-insert-value  ~+
  ;~  pose
    ;~(pfix whitespace ;~(sfix insert-value whitespace))
    ;~(pfix whitespace insert-value)
    ;~(sfix insert-value whitespace)
    insert-value
  ==
::
::  used for various commands
::
++  cook-column
  |=  a=*
    ?.  ?=([@ @] [a])  ~|("cannot parse column  {<a>}" !!)
    ?@  +.a
      (column:ast %column -.a (crip (slag 1 (trip +.a))))
    ~|("cannot parse column  {<a>}" !!)
++  cook-ordered-column
  |=  a=*
    ?@  a
      (ordered-column:ast %ordered-column a %.y)
    ?:  ?=([@ @] [a])
      ?:  =(+.a %asc)
        (ordered-column:ast %ordered-column -.a %.y)
      (ordered-column:ast %ordered-column -.a %.n)
    ~|("cannot parse ordered-column  {<a>}" !!)
++  cook-referential-integrity
  |=  a=*
  ?:  ?=([[@ @] @ @] [a])                  :: <type> cascade, <type> cascade
    ?:  =(%delete -<.a)
      ?:  =(%update +<.a)
        ~[%delete-cascade %update-cascade]
      !!
    ?:  =(%update -<.a)
      ?:  =(%delete +<.a)
        ~[%delete-cascade %update-cascade]
      !!
    !!
  ?:  ?=([@ @] [a])                        :: <type> cascade
    ?:  =(-.a %delete)  [%delete-cascade ~]  [%update-cascade ~]
  ?:  ?=([[@ @] @ @ [@ %~] @] [a])         :: <type> cascade, <type> no action
    ?:  =(-<.a %delete)  [%delete-cascade ~]  [%update-cascade ~]
  ?:  ?=([[@ @ [@ %~] @] @ @] [a])         :: <type> no action, <type> cascade
    ?:  =(+<.a %delete)  [%delete-cascade ~]  [%update-cascade ~]
  ?:  ?=([@ [@ %~]] a)                     :: <type> no action
    ~
  ?:  ?=([[@ @ [@ %~] @] @ @ [@ %~] @] a)  :: <type> no action, <type> no action
    ~
  ~|("cannot parse ordered-column  {<a>}" !!)
++  end-or-next-command  ~+
  ;~  plug  (cold %end-command ;~(pose ;~(plug whitespace mic) whitespace mic))
            (easy ~)
            ==
++  alias  ~+
  %+  cook
    |=(a=tape (rap 3 ^-((list ,@) a)))
  ;~(plug alf (star ;~(pose nud alf hep)))
++  parse-alias  ~+  ;~(pfix whitespace alias)
++  parse-face  ~+  ;~(pfix whitespace sym)
++  face-list  ~+
  ;~  pfix
    whitespace
    %:  ifix  [pal par]
              (more com ;~(pose ;~(sfix parse-face whitespace) parse-face))
              ==
  ==
++  ordering  ;~(pfix whitespace ;~(pose (jester 'asc') (jester 'desc')))
++  ordered-column-list
  ;~  pfix
    whitespace
    %:  ifix
      [pal par]
      %:  more
        com
        %:  cook
          cook-ordered-column
          ;~  pose  ;~(sfix ;~(plug parse-face ordering) whitespace)
                    ;~(plug parse-face ordering)
                    ;~(sfix parse-face whitespace)
                    parse-face
                    ==
          ==
        ==
      ==
    ==
++  on-database  ;~(plug (jester 'database') parse-face)
++  on-namespace
  ;~  plug  (jester 'namespace')
            %:  cook  |=(a=* (qualified-namespace [a default-database]))
                      parse-qualified-2-name
                      ==
            ==
++  parse-aura  ~+
  =/  root-aura  ;~  pose
    (jest '@c')              ::  UTF-32
    (jest '@da')             ::  date
    (jest '@dr')             ::  timespan
    (jest '@f')              ::  loobean
    (jest '@if')             ::  IPv4 address
    (jest '@is')             ::  IPv6 address
    (jest '@p')              ::  ship name
    (jest '@q')              ::  phonemic base, unscrambled
    (jest '@rh')             ::  half precision (16 bits)
    (jest '@rs')             ::  single precision (32 bits)
    (jest '@rd')             ::  double precision (64 bits)
    (jest '@rq')             ::  quad precision (128 bits)
    (jest '@sb')             ::  signed binary
    (jest '@sd')             ::  signed decimal
    (jest '@sv')             ::  signed base32
    (jest '@sw')             ::  signed base64
    (jest '@sx')             ::  signed hexadecimal
    (jest '@t')              ::  UTF-8 text (cord)
    (jest '@ta')             ::  ASCII text (knot)
    (jest '@tas')            ::  ASCII text symbol (term)
    (jest '@ub')             ::  unsigned binary
    (jest '@ud')             ::  unsigned decimal
    (jest '@uv')             ::  unsigned base32
    (jest '@uw')             ::  unsigned base64
    (jest '@ux')             ::  unsigned hexadecimal
    ==
  ;~  pose
    ;~(plug root-aura (shim 'A' 'J'))
    root-aura
  ==
++  parse-as-of  ~+
  ;~  pfix
    whitespace
    ;~  plug
      (cold %as-of ;~(plug (jester 'as') whitespace (jester 'of')))
      ;~  pfix
        whitespace
        ;~  pose
          ;~  plug
            dem
            ;~  pfix
              whitespace
              ;~  pose
                (cold %seconds (jester 'seconds'))
                (cold %minutes (jester 'minutes'))
                (cold %hours (jester 'hours'))
                (cold %days (jester 'days'))
                (cold %weeks (jester 'weeks'))
                (cold %months (jester 'months'))
                (cold %years (jester 'years'))
                (cold %seconds (jester 'second'))
                (cold %minutes (jester 'minute'))
                (cold %hours (jester 'hour'))
                (cold %days (jester 'day'))
                (cold %weeks (jester 'week'))
                (cold %months (jester 'month'))
                (cold %years (jester 'year'))
              ==
            ==
            ;~  pfix
              whitespace
              (cold %ago (jester 'ago'))
            ==
          ==
          ;~(pose ;~(pfix sig crub-no-text) crub-no-text)
          (cold %now (jester 'now'))
        ==
      ==
    ==
  ==
++  aggregate-name
  |=  name=@t
  ^-  @t
  (crip (cass (trip name)))
++  column-defintion-list
  =/  column-definition  ;~  plug
    sym
    ;~(pfix whitespace parse-aura)
    ==
  %:  more
    com
    %:  cook
      cook-column
      ;~  pose
        ;~(pfix whitespace ;~(sfix column-definition whitespace))
        ;~(sfix column-definition whitespace)
        ;~(pfix whitespace column-definition)
        column-definition
      ==
    ==
  ==
++  referential-integrity
  ;~  plug
    ;~  pfix
      ;~(plug whitespace (jester 'on') whitespace)
      ;~(pose (jester 'update') (jester 'delete'))
    ==
    ;~  pfix
      whitespace
      ;~  pose
        (jester 'cascade')
        ;~(plug (jester 'no') whitespace (jester 'action'))
      ==
    ==
  ==
++  column-definitions
  ;~(pfix whitespace (ifix [pal par] column-defintion-list))
++  alter-columns
  ;~  plug
    %:  cold  %alter-column
              ;~(plug whitespace (jester 'alter') whitespace (jester 'column'))
              ==
    column-definitions
  ==
++  add-columns
  ;~  plug
    %:  cold  %add-column
              ;~(plug whitespace (jester 'add') whitespace (jester 'column'))
              ==
    column-definitions
  ==
++  drop-columns
  ;~  plug
    %:  cold  %drop-column
              ;~(plug whitespace (jester 'drop') whitespace (jester 'column'))
              ==
    face-list
  ==
++  parse-datum  ~+
  ;~  pose
    ;~(pose ;~(pfix whitespace parse-qualified-column) parse-qualified-column)
    ;~(pose ;~(pfix whitespace parse-value-literal) parse-value-literal)
  ==
++  cook-aggregate
  |=  parsed=*
  [%aggregate -.parsed +.parsed]
++  parse-aggregate
  ;~  pose
    %:  cook  cook-aggregate
              ;~  pfix
                whitespace
                ;~(plug ;~(sfix parse-alias pal) ;~(sfix get-datum par))
                ==
              ==
    %:  cook  cook-aggregate
              ;~(plug ;~(sfix parse-alias pal) ;~(sfix get-datum par))
              ==
  ==
++  cook-selected-aggregate
  |=  parsed=*
  [%selected-aggregate -.parsed +.parsed]
++  parse-selected-aggregate
  ;~  pose
    %:  cook  cook-selected-aggregate
              ;~  pfix
                whitespace
                ;~(plug ;~(sfix parse-alias pal) ;~(sfix get-datum par))
                ==
              ==
    %:  cook  cook-selected-aggregate
              ;~(plug ;~(sfix parse-alias pal) ;~(sfix get-datum par))
              ==
  ==
::
::  indices
::
++  cook-primary-key
  |=  a=*
  ~+
  ?@  -.a
    (interim-key %interim-key +.a)
  (interim-key %interim-key a)
++  cook-foreign-key
  |=  a=*
  :: foreign key ns.table ... references fk-table ... on action on action
  ?:  ?=([[@ * * [@ @] *] *] [a])
    (foreign-key:ast %foreign-key -<.a ->-.a ->+<-.a ->+<+.a ->+>.a +.a)
  :: foreign key table ... references fk-table ... on action on action
  ?:  ?=([[@ [[@ @ @] %~] @ [@ %~]] *] [a])
    (foreign-key:ast %foreign-key -<.a ->-.a ->+<-.a 'dbo' ->+.a +.a)
  ~|("cannot parse foreign-key  {<a>}" !!)
++  build-foreign-keys
  |=  a=[table=qualified-object:ast f-keys=*]
  =/  f-keys  +.a
  =/  foreign-keys  `(list foreign-key:ast)`~
  |-
  ?:  =(~ f-keys)
    (flop foreign-keys)
  ?@  -<.f-keys
    %=  $                       :: foreign key table must be in same DB as table
      foreign-keys
        :-  %:  foreign-key:ast  %foreign-key
                                  -<.f-keys
                                  -.a
                                  ->-.f-keys
                                  %:  qualified-object:ast  %qualified-object
                                                            ~
                                                            ->+<.a
                                                            ->+<+>+<.f-keys
                                                            ->+<+>+>.f-keys
                                                            ==
                                  ->+>.f-keys
                                  ~
                                  ==
            foreign-keys
      f-keys        +.f-keys
    ==
  %=  $                         :: foreign key table must be in same DB as table
    foreign-keys
      :-  %:  foreign-key:ast  %foreign-key
                              -<-.f-keys
                              -.a
                              -<+<.f-keys
                              %:  qualified-object:ast  %qualified-object
                                                        ~
                                                        ->+<.a
                                                        -<+>->+>-.f-keys
                                                        -<+>->+>+.f-keys
                                                        ==
                              -<+>+.f-keys
                              ->.f-keys
                              ==
          foreign-keys
    f-keys        +.f-keys
  ==
++  foreign-key-literal
  ;~(plug whitespace (jester 'foreign') whitespace (jester 'key'))
++  foreign-key
  ;~  plug
    parse-face
    ordered-column-list
    ;~  pfix
      ;~(plug whitespace (jester 'references'))
      ;~(plug (cook cook-qualified-2object parse-qualified-2-name) face-list)
    ==
  ==
++  full-foreign-key
  ;~  pose
    ;~  plug  foreign-key
              %:  cook  cook-referential-integrity
                        ;~(plug referential-integrity referential-integrity)
                        ==
              ==
    ;~  plug  foreign-key
              %:  cook  cook-referential-integrity
                        ;~(plug referential-integrity referential-integrity)
                        ==
              ==
    ;~(plug foreign-key (cook cook-referential-integrity referential-integrity))
    ;~(plug foreign-key (cook cook-referential-integrity referential-integrity))
    foreign-key
  ==
++  add-foreign-key
  ;~  plug
    (cold %add-fk ;~(plug whitespace (jester 'add')))
    ;~(pfix foreign-key-literal (more com full-foreign-key))
  ==
++  drop-foreign-key
  ;~  plug
    %:  cold  %drop-fk
              ;~  plug  whitespace
                        (jester 'drop')
                        whitespace
                        (jester 'foreign')
                        whitespace
                        (jester 'key')
                        ==
              ==
    face-list
  ==
++  primary-key
   %:  cook
    cook-primary-key
    ;~  pfix
      ;~(plug whitespace (jester 'primary') whitespace (jester 'key'))
      ordered-column-list
      ==
  ==
::
::  query object and joins
::
++  join-stop  ~+
  ;~  pose
    ;~(plug (jester 'where') whitespace)
    ;~(plug (jester 'scalar') whitespace)
    ;~(plug (jester 'group') whitespace)
    ;~(plug (jester 'select') whitespace)
    ;~(plug (jester 'join') whitespace)
    ;~(plug (jester 'left') whitespace)
    ;~(plug (jester 'right') whitespace)
    ;~(plug (jester 'outer') whitespace)
    ;~(plug (jester 'cross') whitespace)
    ;~(plug (jester 'on') whitespace)
    ;~(plug (jester 'as') whitespace)
  ==
++  query-object  ~+
  ;~  pose
    ;~  plug                :: AS <alias> <as-of-time>
      parse-qualified-object
      parse-as-of
      ;~(pfix whitespace ;~(pfix (jester 'as') parse-alias)) 
    ==
    ;~  plug                :: <alias> <as-of-time>
      parse-qualified-object
      parse-as-of
      ;~(pfix whitespace ;~(less join-stop parse-alias))
    ==
    ;~  plug                :: <as-of-time>
      parse-qualified-object
      parse-as-of
    == 
    ;~  plug                  :: AS <alias>
      parse-qualified-object
      ;~(pfix whitespace ;~(pfix (jester 'as') parse-alias))
    ==
    ;~  plug                  :: <alias>
      parse-qualified-object
      ;~(pfix whitespace ;~(less join-stop parse-alias))
    ==
    parse-qualified-object    :: no alias, no as-of
    ::    
    %:  stag
      %query-row
      ;~(plug face-list ;~(pfix whitespace ;~(pfix (jester 'as') parse-alias)))
    ==
    %:  stag
      %query-row
      ;~(plug face-list ;~(pfix whitespace ;~(less join-stop parse-alias)))
    ==
    (stag %query-row face-list)
  ==
++  parse-join-type  ~+
  ;~  pfix  whitespace
    ;~  pose
      (cold %join (jester 'join'))
      (cold %left-join ;~(plug (jester 'left') whitespace (jester 'join')))
      (cold %right-join ;~(plug (jester 'right') whitespace (jester 'join')))
      %:  cold  %outer-join-all
                ;~  plug
                  (jester 'outer')
                  whitespace
                  (jester 'join')
                  whitespace
                  (jester 'all')
                ==
      ==
      (cold %outer-join ;~(plug (jester 'outer') whitespace (jester 'join')))
    ==
  ==
++  parse-cross-join-type  ~+
  ;~  pfix
    whitespace
    (cold %cross-join ;~(plug (jester 'cross') whitespace (jester 'join')))
  ==
++  build-query-object  ~+
  |=  parsed=*
  ^-  $?  table-set:ast
          [table-set:ast as-of-offset:ast]
          [table-set:ast as-of:ast]
          ==
   ?:  ?=([[%qualified-object (unit @p) @ @ @ (unit @t)] @] parsed)
    %+  table-set:ast  %table-set
                       :*  %qualified-object
                           ->-.parsed
                           ->+<.parsed
                           ->+>-.parsed
                           ->+>+<.parsed
                           `+.parsed
                           ==
  ?:  ?=([[%qualified-object (unit @p) @ @ @ (unit @t)]] parsed)
    (table-set:ast %table-set parsed)
  ::
  ?:  ?=([[%qualified-object (unit @p) @ @ @ (unit @t)] %as-of %now] parsed)
    :-  (table-set:ast %table-set -.parsed)
        (as-of-offset:ast %as-of-offset 0 %seconds)
  ?:  ?=([[%qualified-object (unit @p) @ @ @ (unit @t)] [%as-of %now] @] parsed)
    :-  %+  table-set:ast  %table-set
                           :*  %qualified-object
                               ->-.parsed
                               ->+<.parsed
                               ->+>-.parsed
                               ->+>+<.parsed
                               `+>.parsed
                               ==
        (as-of-offset:ast %as-of-offset 0 %seconds)
  ::
  ?:  ?=  [[%qualified-object (unit @p) @ @ @ (unit @t)] [%as-of @ @ %ago]]
          parsed
    :-  (table-set:ast %table-set -.parsed)
        (as-of-offset:ast %as-of-offset +>-.parsed +>+<.parsed)
  ?:  ?=  [[%qualified-object (unit @p) @ @ @ (unit @t)] [%as-of @ @ %ago] @]
          parsed
    :-  %+  table-set:ast  %table-set
                           :*  %qualified-object
                               ->-.parsed
                               ->+<.parsed
                               ->+>-.parsed
                               ->+>+<.parsed
                               `+>.parsed
                               ==
        (as-of-offset:ast %as-of-offset +<+<.parsed +<+>-.parsed)
  ::
  ?:  ?=([[%qualified-object (unit @p) @ @ @ (unit @t)] [%as-of @ @]] parsed)
    :-  (table-set:ast %table-set -.parsed)
        ;;(as-of:ast [+>-.parsed +>+.parsed])
  ?:  ?=([[%qualified-object (unit @p) @ @ @ (unit @t)] [%as-of @ @] @] parsed)
    :-  %+  table-set:ast  %table-set
                           :*  %qualified-object
                               ->-.parsed
                               ->+<.parsed
                               ->+>-.parsed
                               ->+>+<.parsed
                               `+>.parsed
                               ==
        ;;(as-of:ast [+<+<.parsed +<+>.parsed])
  ::
  ?:  =(%query-row -.parsed)  ;;(table-set:ast parsed)
  ~|("cannot parse query-object  {<parsed>}" !!)
::
++  parse-query-object  ~+
  ;~  pfix
    whitespace
    (cook build-query-object query-object)
  ==
++  parse-cross-join-obj  ~+
  ;~(plug parse-cross-join-type parse-query-object)
++  parse-natural-join
  ;~  plug
    ;~  pfix  whitespace
      (cold %join (jester 'join'))
    ==
    parse-query-object
  ==
++  parse-join-obj  ~+
  ;~  plug
    parse-join-type
    parse-query-object
    ;~(pfix whitespace ;~(pfix (jester 'on') parse-predicate))
  ==
++  parse-object-and-joins  ~+
  ;~  plug
    parse-query-object
    (star ;~(pose parse-join-obj parse-natural-join parse-cross-join-obj))
  ==
++  make-query-object
  |=  a=*
  ^-  table-set:ast
  ?:  ?=(qualified-object:ast a)
    (table-set:ast %table-set a)
  ?:  ?=(qualified-object:ast -.a)
    ?~  +.a  (table-set:ast %table-set -.a)
    ?:  ?=((unit @t) +.a)
      (table-set:ast %table-set -.a +.a)
    %+  table-set:ast  %table-set
                       [%qualified-object ->-.a ->+<.a ->+>-.a ->+>+<.a `+.a]
  ?:  ?=([@ @] a)
    %+  table-set:ast
      %table-set
      %:  qualified-object:ast  %qualified-object
                                ~
                                'UNKNOWN'
                                'COLUMN-OR-CTE'
                                -.a
                                `+.a
                                ==
  ::  %query-row not implemented
  =/  columns=(list @t)  ~
  =/  b  ?:  ?=([%query-row * @] a)  +<.a
    ?:  =(%query-row -.a)  +.a
    ?:  =(%query-row -<.a)  ->.a  -.a
  =/  alias  ?:  ?=([%query-row * @] a)  +>.a
    ?:  =(%query-row -.a)  ~  +.a
  |-
  ?~  b
    ?~  alias
      %:  table-set:ast
        %table-set
        object=(query-row:ast %query-row (flop columns))
        ~
      ==
    %:  table-set:ast
      %table-set
      object=(query-row:ast %query-row (flop columns))
      `alias
    ==
  ?@  -.b  $(b +.b, columns [-.b columns])
  ~|("cannot make-query-object:  {<a>}" !!)
::
::  column in "join on" or "where" predicate, qualified or aliased
::  indeterminate qualification and aliasing is determined later
::
++  cook-qualified-column
  |=  a=*
  ~+
  ?:  ?=([@ @ @ @ @] a) :: @p.db.ns.object.column
    %:  qualified-column:ast
      %qualified-column
      (qualified-object:ast %qualified-object `-.a +<.a +>-.a +>+<.a ~)
      +>+>.a
      ~
    ==
  ?:  ?=([@ @ @ @ @ @] a) :: @p.db..object.column
    %:  qualified-column:ast
      %qualified-column
      (qualified-object:ast %qualified-object `-.a +<.a 'dbo' +>+>-.a ~)
      +>+>+.a
      ~
    ==
  ?:  ?=([@ @ @ @] a)   :: db..object.column; db.ns.object.column
    ?:  =(+<.a '.')
      %:  qualified-column:ast
        %qualified-column
        (qualified-object:ast %qualified-object ~ -.a 'dbo' +>-.a ~)
        +>+.a
        ~
      ==
    %:  qualified-column:ast
      %qualified-column
      (qualified-object:ast %qualified-object ~ -.a +<.a +>-.a ~)
      +>+.a
      ~
    ==
  ?:  ?=([@ @ @] a)     :: ns.object.column
    %:  qualified-column:ast
      %qualified-column
      (qualified-object:ast %qualified-object ~ default-database -.a +<.a ~)
      +>.a
      ~
    ==
  ?:  ?=([@ @] a)       :: something.column (could be table, table alias or cte)
    %:  qualified-column:ast
      %qualified-column
      (qualified-object:ast %qualified-object ~ 'UNKNOWN' 'COLUMN' -.a ~)
      +.a
      ~
    ==
  ?@  a                 :: column, column alias, or cte
    %:  qualified-column:ast
      %qualified-column
      (qualified-object:ast %qualified-object ~ 'UNKNOWN' 'COLUMN-OR-CTE' a ~)
      a
      ~
    ==
  ~|("cannot parse qualified-column  {<a>}" !!)
++  parse-column  ~+
  ;~  pose
    ;~((glue dot) parse-ship sym sym sym sym)
    ;~(plug parse-ship ;~(pfix dot sym) dot dot sym ;~(pfix dot sym))
    ;~((glue dot) sym sym sym sym)
    ;~(plug sym dot ;~(pfix dot sym) ;~(pfix dot sym))
    ;~((glue dot) sym sym sym)
    ;~(plug mixed-case-symbol ;~(pfix dot sym))
    sym
  ==
++  parse-qualified-column  ~+  (cook cook-qualified-column parse-column)
::
::  predicate
::
++  parse-operator  ~+
  ;~  pose
      ::  binary operators
    (cold %eq (just '='))
    (cold %neq ;~(pose (jest '<>') (jest '!=')))
    (cold %gte ;~(pose (jest '>=') (jest '!<')))
    (cold %lte ;~(pose (jest '<=') (jest '!>')))
    (cold %gt (just '>'))
    (cold %lt (just '<'))
    (cold %in ;~(plug (jester 'in') whitespace))
    %:  cold  %not-in
              ;~(plug (jester 'not') whitespace (jester 'in') whitespace)
              ==
    (cold %equiv ;~(plug (jester 'equiv') whitespace))
    %:  cold  %not-equiv
              ;~(plug (jester 'not') whitespace (jester 'equiv') whitespace)
              ==
      :: conjunctions
    (cold %and ;~(plug (jester 'and') whitespace))
    (cold %or ;~(plug (jester 'or') whitespace))
      :: ternary operators
    (cold %between ;~(plug (jester 'between') whitespace))
    %:  cold  %not-between
              ;~(plug (jester 'not') whitespace (jester 'between') whitespace)
              ==
      :: unary operators
    %:  cold  %not-exists
              ;~(plug (jester 'not') whitespace (jester 'exists') whitespace)
              ==
    (cold %exists ;~(plug (jester 'exists') whitespace))
    (cold %any ;~(plug (jester 'any') whitespace))
    (cold %all ;~(plug (jester 'all') whitespace))
      :: nesting
    (cold %pal pal)
    (cold %par par)
  ==
++  predicate-list  ~+
  |=  a=*
  ^-  (list raw-pred-cmpnt)
  =/  new-list=(list raw-pred-cmpnt)  ~
  |-
  ?:  =(a ~)  (flop new-list)
  ?:  ?=(parens -.a)
    $(new-list [i=`parens`-.a t=new-list], a +.a)
  ?:  ?=(ops-and-conjs:ast -.a)
    $(new-list [i=`ops-and-conjs:ast`-.a t=new-list], a +.a)
  ?:  ?=(qualified-column:ast -.a)
    $(new-list [i=`qualified-column:ast`-.a t=new-list], a +.a)
  ?:  ?=(dime -.a)
    $(new-list [i=`dime`-.a t=new-list], a +.a)
  ?:  ?=(value-literals:ast -.a)
    $(new-list [i=`value-literals:ast`-.a t=new-list], a +.a)
  ?:  ?&(=(%aggregate:ast -<.a) ?=(@ ->-.a) ?=(qualified-column:ast ->+.a))
    %=  $
      new-list
        :-  %:  aggregate:ast   %aggregate
                               (aggregate-name ->-.a)
                               `qualified-column:ast`->+.a
                               ==
            new-list
      a  +.a
    ==
  ~|("problem with predicate noun:  {<a>}" !!)
++  predicate-stop  ~+
  ;~  pose
    ;~(plug whitespace mic)
    mic
    ;~(plug whitespace (jester 'where') whitespace)
    ;~(plug whitespace (jester 'when') whitespace)
    ;~(plug whitespace (jester 'select') whitespace)
    ;~(plug whitespace (jester 'as') whitespace)
    ;~(plug whitespace (jester 'join') whitespace)
    ;~(plug whitespace (jester 'left') whitespace)
    ;~(plug whitespace (jester 'right') whitespace)
    ;~(plug whitespace (jester 'outer') whitespace)
    ;~(plug whitespace (jester 'then') whitespace)
    ;~(plug whitespace (jester 'group') whitespace (jester 'by') whitespace)
  ==
++  predicate-part  ~+
  ;~  pose
    parse-aggregate
    value-literal-list
    ;~(pose ;~(pfix whitespace parse-operator) parse-operator)
    parse-datum
  ==
++  parse-predicate  ~+
  (star ;~(less predicate-stop predicate-part))
::
::  when not qualified by () right conjunction takes precedence and "or"
::  takes precedence over "and"
::
::  1=1 and 1=3 (false)
::       /\
::    1=1  11=3
::
::  1=1 and 1=3 and 1=4 (false)
::               /\
::              &  1=4
::             /\
::          1=1  1=3
::
::  1=2 and 3=3 and 1=4 or 1=1 (true)
::                      /\
::                     &  1=1
::                    /\
::                   &  1=4
::                  /\
::               1=1  3=3
::
::  1=2 and 3=3 and 1=4 or 1=1 and 1=4 (false)
::                      /\
::                     &  1=1 and 1=4
::                    /\
::                   &  1=4
::                  /\
::               1=2  3=3
::
::  1=2 and 3=3 and 1=4 or 1=1 and 1=4 or 2=2 (true)
::                                     /\
::                                    |  2=2
::                                   /\
::                                  &  1=1 and 1=4
::                                 /\
::                                &  1=4
::                               /\
::                            1=2  3=3
::
::  1=2 and 3=3 and 1=4 or 1=1 and 1=4 or 2=2 and 3=2 (false)
::                                     /\
::                                    |  2=2 and 3=2
::                                   /\
::                                  &  1=1 and 1=4
::                                 /\
::                                &  1=4
::                               /\
::                            1=2  3=3
::
++  produce-predicate
  |=  parsed=(list raw-pred-cmpnt)
  ~+
  ^-  predicate:ast
  =/  length  (lent parsed)
  =/  state  (fold (flop parsed) [length 0 ~ 0 parsed] pred-folder)
  ?~  cmpnt.state
    ?:  =(%pal -.parsed)
      (produce-predicate (scag (sub length 2) `(list raw-pred-cmpnt)`+.parsed))
    (pred-leaf parsed)
  =/  r=(pair (list raw-pred-cmpnt) (list raw-pred-cmpnt))
        (split-at parsed cmpnt-displ.state)
  ?+  -.q.r  ~|("unknown predicate node {<-.q.r>}" !!)
    unary-op:ast     :: ?(%not-exists %exists)
      [-.q.r (produce-predicate `(list raw-pred-cmpnt)`+.q.r) ~]
    binary-op:ast    :: ?(%eq inequality-op %equiv %not-equiv %in)
      [-.q.r (produce-predicate p.r) (produce-predicate +.q.r)]
    ternary-op:ast   :: %between, %not-between
      ?:  =(%and +>-.q.r)
        :+  -.q.r
            [%gte (pred-leaf p.r) (pred-leaf (limo ~[+<.q.r]))]
            [%lte (pred-leaf p.r) (pred-leaf (limo +>+.q.r))]
      :+  -.q.r
        [%gte (pred-leaf p.r) (pred-leaf (limo ~[+<.q.r]))]
        [%lte (pred-leaf p.r) (pred-leaf (limo +>.q.r))]
    conjunction:ast  :: ?(%and %or)
      [-.q.r (produce-predicate p.r) (produce-predicate +.q.r)]
    all-any-op:ast   :: ?(%all %any)
      [-.q.r (produce-predicate `(list raw-pred-cmpnt)`+.q.r) ~]
  ==
::
::    +pred-folder  [raw-pred-cmpnt pred-folder-state] -> pred-folder-state
++  pred-folder
  |=  [pred-comp=raw-pred-cmpnt state=pred-folder-state]
  ^-  pred-folder-state
  ?+  pred-comp  (advance-pred-folder-state state)
    ::
    :: parens alter the level
    %pal
      :*  (dec displ.state)
          (dec level.state)
          cmpnt.state
          cmpnt-displ.state
          the-list.state
          ==
    %par
      :*  (dec displ.state)
          +(level.state)
          cmpnt.state
          cmpnt-displ.state
          the-list.state
          ==
    ::
    :: these operators have equivalent precendence, choose first in lowest level
    unary-op:ast     :: ?(%not %exists)
      ?:  &(=(level.state 0) =(cmpnt.state ~))
        (update-pred-folder-state pred-comp state)
      (advance-pred-folder-state state)
    binary-op:ast    :: ?(%eq inequality-op %equiv %not-equiv %in)
      ?:  &(=(level.state 0) =(cmpnt.state ~))
        (update-pred-folder-state pred-comp state)
      :: binary-op takes precedence over all-any-op
      ?:  ?&  =(level.state 0)
              !=(cmpnt.state `%and)
              !=(cmpnt.state `%or)
              ?|  =((snag displ.state the-list.state) %all)
                  =((snag displ.state the-list.state) %any)
                  ==
              ==
        (update-pred-folder-state pred-comp state)
      (advance-pred-folder-state state)
    ternary-op:ast   :: ?(%between %not-between)
      ?:  &(=(level.state 0) =(cmpnt.state ~))
        (update-pred-folder-state pred-comp state)
      (advance-pred-folder-state state)
    all-any-op:ast   :: ?(%all %any)
      ?:  &(=(level.state 0) =(cmpnt.state ~))
        (update-pred-folder-state pred-comp state)
      (advance-pred-folder-state state)
    ::
    :: 2nd highest precedence
    %and  :: skip if the %and is of a ternary-op
      ?:  ?&  =(level.state 0)
              (gth displ.state 3)
              ?|  =((snag (sub displ.state 3) the-list.state) %between)
                  =((snag (sub displ.state 3) the-list.state) %not-between)
                  ==
              ==
        (advance-pred-folder-state state)
      ?:  &(=(level.state 0) =(cmpnt.state ~))
        (update-pred-folder-state pred-comp state)
      ?:  ?|(=(`%and cmpnt.state) =(`%or cmpnt.state))
        (advance-pred-folder-state state)
      ?:  =(level.state 0)
        (update-pred-folder-state pred-comp state)
      (advance-pred-folder-state state)
    ::
    :: highest precedence
    %or
      ?:  &(=(level.state 0) =(cmpnt.state ~))
        (update-pred-folder-state pred-comp state)
      ?:  =(`%or cmpnt.state)
        (advance-pred-folder-state state)
      ?:  =(level.state 0)
        (update-pred-folder-state pred-comp state)
      (advance-pred-folder-state state)
  ==
+$  pred-folder-state
  $:
    displ=@
    level=@
    cmpnt=(unit raw-pred-cmpnt)
    cmpnt-displ=@
    the-list=(list raw-pred-cmpnt)
  ==
::
::    +split-at: [(list T) index:@] -> [(list T) (list T)]
++  split-at
  |*  [p=(list) i=@]
  [(scag i p) (slag i p)]
::
::    +fold: [(list T1) state:T2 folder:$-([T1 T2] T2)] -> T2
++  fold
  |=  [a=(list raw-pred-cmpnt) b=pred-folder-state c=_pred-folder]
  |-  ^+  b
  ?~  a  b
  $(a t.a, b (c i.a b))
++  update-pred-folder-state
  |=  [pred-comp=raw-pred-cmpnt state=pred-folder-state]
  ^-  pred-folder-state
  :*  (dec displ.state)
      level.state
      `pred-comp
      (dec displ.state)
      the-list.state
      ==
++  advance-pred-folder-state
  |=  state=pred-folder-state
  ^-  pred-folder-state
  :*  (dec displ.state)
      level.state
      cmpnt.state
      cmpnt-displ.state
      the-list.state
      ==
::
::  parse scalar
::
++  get-datum  ~+
  ;~  pose
    ;~(sfix parse-qualified-column whitespace)
    ;~(sfix parse-value-literal whitespace)
    ;~(sfix parse-datum whitespace)
    parse-datum
  ==
::++  cook-if
::  |=  parsed=*
::  ^-  if-then-else:ast
::  (if-then-else:ast %if-then-else -.parsed +>-.parsed +>+>-.parsed)
++  parse-if
  ;~  plug
    parse-predicate
    ;~(pfix whitespace (cold %then (jester 'then')))
    ;~(pose scalar-body parse-datum)
    ;~(pfix whitespace (cold %else (jester 'else')))
    ;~(pose scalar-body parse-datum)
    ;~(pfix whitespace (cold %endif (jester 'endif')))
  ==
++  parse-when-then
  ;~  plug
    ;~(pfix whitespace (cold %when (jester 'when')))
    ;~(pose parse-predicate parse-datum)
    ;~(pfix whitespace (cold %then (jester 'then')))
    ;~(pose parse-aggregate scalar-body parse-datum)
  ==
++  parse-case-else
  ;~  plug
    ;~(pfix whitespace (cold %else (jester 'else')))
    ;~(pfix whitespace ;~(pose parse-aggregate scalar-body parse-datum))
    ;~(pfix whitespace (cold %end (jester 'end')))
  ==
++  cook-case
  |=  parsed=*
  ~+
  =/  raw-cases   +<.parsed
  =/  cases=(list case-when-then:ast)  ~
  |-
  ?.  =(raw-cases ~)
    %=  $
      cases      [(case-when-then:ast ->-.raw-cases ->+>.raw-cases) cases]
      raw-cases  +.raw-cases
    ==
  ?:  ?=(qualified-column:ast -.parsed)
    ?:  =('else' +>-.parsed)  (case:ast %case -.parsed (flop cases) +>+<.parsed)
      (case:ast %case -.parsed (flop cases) ~)
  ?:  ?=(dime -.parsed)
    ?:  =('else' +>-.parsed)  (case:ast %case -.parsed (flop cases) +>+<.parsed)
      (case:ast %case -.parsed (flop cases) ~)
  ~|("cannot parse case  {<parsed>}" !!)
++  parse-case
  ;~  plug
    parse-datum
    (star parse-when-then)
    ;~(pose parse-case-else ;~(pfix whitespace (cold %end (jester 'end'))))
  ==
::
++  scalar-token
  ;~  pose
    ;~(pfix whitespace (cold %end (jester 'end')))
    ;~(pfix whitespace ;~(plug (cold %if (jester 'if')) parse-if))
    ;~(plug (cold %if (jester 'if')) parse-if)
    ;~(pfix whitespace ;~(plug (cold %case (jester 'case')) parse-case))
    ;~(plug (cold %case (jester 'case')) parse-case)
    ;~  pfix  whitespace
              ;~(plug (cold %coalesce (jester 'coalesce')) parse-coalesce)
              ==
    ;~(plug (cold %coalesce (jester 'coalesce')) parse-coalesce)
    (cold %pal ;~(plug whitespace pal))
    (cold %pal pal)
    (cold %par ;~(plug whitespace par))
    (cold %par par)
    (cold %lus ;~(plug whitespace lus))
    (cold %lus lus)
    (cold %hep ;~(plug whitespace hep))
    (cold %hep hep)
    (cold %tar ;~(plug whitespace tar))
    (cold %tar tar)
    (cold %fas ;~(plug whitespace fas))
    (cold %fas fas)
    (cold %ket ;~(plug whitespace ket))
    (cold %ket ket)
    parse-datum
  ==
++  parse-coalesce  ~+  (more com ;~(pose parse-aggregate get-datum))
++  parse-math
  ;~  plug
    (cold %begin (jester 'begin'))
    (star scalar-token)
  ==
++  parse-scalar-body
  %+
    knee  *noun
    |.  ~+
    ;~  pose
      ;~(plug (cold %if (jester 'if')) parse-if)
      ;~(plug (cold %case (jester 'case')) parse-case)
      ;~(plug (cold %coalesce (jester 'coalesce')) parse-coalesce)
      parse-math
  ==
++  scalar-stop  ;~
  pose
    ;~(plug whitespace (jester 'where'))
    ;~(plug whitespace (jester 'scalar'))
    ;~(plug whitespace (jester 'select'))
  ==
++  scalar-body  ;~(pfix whitespace parse-scalar-body)
++  parse-scalar-part  ~+
  ;~  plug
    (cold %scalar ;~(pfix whitespace (jester 'scalar')))
    parse-face
  ==
++  parse-scalar
  ;~  pose
    ;~  plug  parse-scalar-part
              ;~(pfix ;~(plug whitespace (jester 'as')) scalar-body)
              ==
    ;~(plug parse-scalar-part scalar-body)
  ==
::
::  select
::
++  parse-alias-all  (stag %all-columns ;~(sfix parse-alias ;~(plug dot tar)))
++  parse-object-all
  (stag %all-columns ;~(sfix parse-qualified-object ;~(plug dot tar)))
++  parse-selection  ~+
  ;~  pose
    ;~  plug
      ;~(sfix parse-selected-aggregate whitespace)
      (cold %as (jester 'as'))
      ;~(pfix whitespace alias)
    ==
    parse-selected-aggregate
    parse-alias-all
    parse-object-all
    ;~  plug
      ;~(sfix ;~(pose parse-qualified-column parse-value-literal) whitespace)
      (cold %as (jester 'as'))
      ;~(pfix whitespace alias)
    ==
    ;~(pose parse-qualified-column parse-value-literal)
    (cold %all tar)
  ==
++  select-column
  ;~  pose
    (ifix [whitespace whitespace] parse-selection)
    ;~(plug whitespace parse-selection)
    parse-selection
  ==
++  select-columns
  ;~  pose
    (more com select-column)
    select-column
  ==
++  select-top-bottom
  ;~  plug
    (cold %top ;~(plug whitespace (jester 'top')))
    ;~(pfix whitespace dem)
    (cold %bottom ;~(plug whitespace (jester 'bottom')))
    ;~(pfix whitespace dem)
    select-columns
  ==
++  select-top
  ;~  plug
    (cold %top ;~(plug whitespace (jester 'top')))
    ;~(pfix whitespace dem)
    ;~(less ;~(plug whitespace (jester 'bottom')) select-columns)
  ==
++  select-bottom
  ;~  plug
    (cold %bottom ;~(plug whitespace (jester 'bottom')))
    ;~(pfix whitespace dem)
    select-columns
  ==
++  parse-select
  ;~  plug
    (cold %select ;~(plug whitespace (jester 'select')))
    ;~  pose
      select-top-bottom
      select-top
      select-bottom
      select-columns
    ==
  ==
::
::  group and order by
::
++  parse-grouping-column
  (ifix [whitespace whitespace] ;~(pose parse-qualified-column dem))
++  parse-group-by
  ;~  plug
    %:  cold  %group-by
              ;~(plug whitespace (jester 'group') whitespace (jester 'by'))
              ==
    (more com parse-grouping-column)
  ==
++  cook-ordering-column
  |=  parsed=*
  ?:  ?=(qualified-column:ast parsed)
    (ordering-column:ast %ordering-column parsed %.y)
  ?@  parsed  (ordering-column:ast %ordering-column parsed %.y)
  ?:  =(+.parsed %asc)  (ordering-column:ast %ordering-column -.parsed %.y)
  (ordering-column:ast %ordering-column -.parsed %.n)
++  parse-ordered-column
  %:  cook
    cook-ordering-column
    ;~  plug
      ;~(pose parse-qualified-column dem)
      ;~  pfix
        whitespace
        ;~(pose (cold %asc (jester 'asc')) (cold %desc (jester 'desc')))
      ==
    ==
  ==
++  parse-ordering-column
  ;~  pose
    (ifix [whitespace whitespace] parse-ordered-column)
    %:  cook
      cook-ordering-column
      (ifix [whitespace whitespace] ;~(pose parse-qualified-column dem))
    ==
  ==
++  parse-order-by
  ;~  plug
    %:  cold  %order-by
              ;~(plug whitespace (jester 'order') whitespace (jester 'by'))
              ==
    (more com parse-ordering-column)
  ==
--
