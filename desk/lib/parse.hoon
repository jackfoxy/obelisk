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
  ~|  "PARSER: "
  ?-  `urql-command`p.command-nail
    %alter-index
      =/  [parsed=* nail=edge]  |-
                                =/  nail  
                                    ~|  "alter index parse phase:  ".
                                        "{<`tape`(scag 100 q.q.command-nail)>}".
                                        " ..."
                                        %-  parse-alter-index
                                              [[1 1] q.q.command-nail]
                                [(wonk nail) nail]
      %=  $
        script    q.q.u.+3.q:nail
        commands  :-  ~|  "alter index parse produce phase:  ".
                          "{<`tape`(scag 100 q.q.command-nail)>} ..."
              :: qualifier w/o ship or alias
              ?:  ?=  $:  [%qualified-table ~ @ @ @ ~]
                          [%qualified-table ~ @ @ @ ~]
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
              ?:  ?=  $:  [%qualified-table ~ @ @ @ ~]
                          [%qualified-table ~ @ @ @ ~]
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
              ?:  ?=  $:  [%qualified-table ~ @ @ @ ~]
                          [%qualified-table ~ @ @ @ ~]
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
              ?:  ?=  $:  [%qualified-table ~ @ @ @ ~]
                          [%qualified-table ~ @ @ @ ~]
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
      =/  [parsed=* nail=edge]  |-
                                =/  nail  
                                    ~|  "alter namespace parse phase:  ".
                                        "{<`tape`(scag 100 q.q.command-nail)>}".
                                        " ..."
                                        %-  parse-alter-namespace
                                              [[1 1] q.q.command-nail]
                                [(wonk nail) nail]
      %=  $
        script    q.q.u.+3.q:nail
        commands
          :-  ~|  "alter namespace parse produce phase:  ".
                          "{<`tape`(scag 100 q.q.command-nail)>} ..."
              ?:  =(%as-of +>+<.parsed)
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
      =/  [parsed=* nail=edge]  |-
                                =/  nail  
                                    ~|  "alter table parse phase:  ".
                                        "{<`tape`(scag 100 q.q.command-nail)>}".
                                        " ..."
                                        %-  parse-alter-table
                                              [[1 1] q.q.command-nail]
                                [(wonk nail) nail]
      ~|  "alter table parse produce phase:  ".
          "{<`tape`(scag 100 q.q.command-nail)>} ..."
          ?:  =(+<.parsed %alter-column)
            %=  $
              script    q.q.u.+3.q:nail
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
              script    q.q.u.+3.q:nail
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
              script    q.q.u.+3.q:nail
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
              script    q.q.u.+3.q:nail
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
              script    q.q.u.+3.q:nail
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
              script    q.q.u.+3.q:nail
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
              script    q.q.u.+3.q:nail
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
              script    q.q.u.+3.q:nail
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
              script    q.q.u.+3.q:nail
              commands
                ?:  =(%now +>+.parsed)
                  :-  %:  alter-table:ast  %alter-table
                                           -.parsed
                                           ~
                                           ~
                                           ~
                                           %-  build-foreign-keys
                                                 [-.parsed +<+.parsed]
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
                                          %-  build-foreign-keys
                                                [-.parsed +<+.parsed]
                                           ~
                                           [~ +>+.parsed]
                                           ==
                      commands
                :-  %:  alter-table:ast  %alter-table
                                         -.parsed
                                         ~
                                         ~
                                         ~
                                        %-  build-foreign-keys
                                              [-.parsed +<+.parsed]
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
              script    q.q.u.+3.q:nail
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
      =/  [parsed=* nail=edge]  |-
                                =/  nail  
                                    ~|  "create database parse phase:  ".
                                        "{<`tape`(scag 100 q.q.command-nail)>}".
                                        " ..."
                                        %-  parse-create-database
                                              [[1 1] q.q.command-nail]
                                [(wonk nail) nail]
      ~|  "create database parse produce phase:  ".
          "{<`tape`(scag 100 q.q.command-nail)>} ..."
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
      =/  [parsed=* nail=edge]  |-
                                =/  nail  
                                    ~|  "create index parse phase:  ".
                                        "{<`tape`(scag 100 q.q.command-nail)>}".
                                        " ..."
                                        %-  parse-create-index
                                              [[1 1] q.q.command-nail]
                                [(wonk nail) nail]
      ~|  "create index parse produce phase:  ".
          "{<`tape`(scag 100 q.q.command-nail)>} ..."
          ?:  ?=([@ [* *]] [parsed])                 ::"create index ..."
            %=  $
              script    q.q.u.+3.q:nail
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
            ?:  =(-<.parsed %unique)                 ::"create unique index ..."
                %=  $
                  script    q.q.u.+3.q:nail
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
      =/  [parsed=* nail=edge]  |-
                                =/  nail  
                                    ~|  "create namespace parse phase:  ".
                                        "{<`tape`(scag 100 q.q.command-nail)>}".
                                        " ..."
                                        %-  parse-create-namespace
                                              [[1 1] q.q.command-nail]
                                [(wonk nail) nail]
      ~|  "create namespace parse produce phase:  ".
          "{<`tape`(scag 100 q.q.command-nail)>} ..."
          ?@  parsed
            %=  $
              script    q.q.u.+3.q:nail
              commands  :-  %:  create-namespace:ast  %create-namespace
                                                      default-database
                                                      parsed
                                                      ~
                                                      ==
                            commands
            ==
          ?:  ?=([@ @] parsed)
            %=  $
              script    q.q.u.+3.q:nail
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
              script        q.q.u.+3.q:nail
              commands  ?@  id
                :-  %:  create-namespace:ast  %create-namespace
                                              default-database
                                              id
                                              ~
                                              ==
                    commands
              :-  (create-namespace:ast %create-namespace -.id +.id ~)
                  commands
            ==
          =/  asof  +>.parsed
          ?:  ?=([@ @] asof)
            %=  $
              script    q.q.u.+3.q:nail
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
            script    q.q.u.+3.q:nail
            commands  ?@  id
              :-  %:  create-namespace:ast  %create-namespace
                                            default-database
                                            id
                                            :-  ~
                                                %:  as-of-offset:ast
                                                      %as-of-offset
                                                      -.asof
                                                      +<.asof
                                                      ==
                                            ==
                  commands
            :-  %:  create-namespace:ast  %create-namespace
                                          -.id
                                          +.id
                                          :-  ~
                                              %:  as-of-offset:ast
                                                    %as-of-offset
                                                    -.asof
                                                    +<.asof
                                                    ==
                                          ==
                commands
          ==
    %create-table
      =/  [parsed=* nail=edge]  |-
                                =/  nail  
                                    ~|  "create table parse phase:  ".
                                        "{<`tape`(scag 100 q.q.command-nail)>}".
                                        " ..."
                                        %-  parse-create-table
                                              [[1 1] q.q.command-nail]
                                [(wonk nail) nail]
      ~|  "create table parse produce phase:  ".
          "{<`tape`(scag 100 q.q.command-nail)>} ..."
          ?:  ?=([* * [@ *]] parsed)
            %=  $                                       :: no foreign keys
              script    q.q.u.+3.q:nail
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
              script    q.q.u.+3.q:nail
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
              script    q.q.u.+3.q:nail
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
              script    q.q.u.+3.q:nail
              commands
                :-  %:  create-table:ast  %create-table
                                          -.parsed
                                          +<.parsed
                                          +>->.parsed
                                          ~
                                          :-  ~
                                              %:  as-of-offset:ast
                                                    %as-of-offset
                                                    +>+>-.parsed
                                                    +>+>+<.parsed
                                                    ==
                                          ==
                    commands
            ==
          ?:  ?=([* * * %as-of %now] parsed)
            %=  $
              script    q.q.u.+3.q:nail
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
              script    q.q.u.+3.q:nail
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
              script    q.q.u.+3.q:nail
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
            script    q.q.u.+3.q:nail
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
      =/  [parsed=* nail=edge]  |-
                                =/  nail  
                                    ~|  "delete parse phase:  ".
                                        "{<`tape`(scag 100 q.q.command-nail)>}".
                                        " ..."
                                        %-  parse-delete
                                              [[1 1] q.q.command-nail]
                                [(wonk nail) nail]
      ~|  "delete parse produce phase:  ".
          "{<`tape`(scag 100 q.q.command-nail)>} ..."
          %=  $
            script    q.q.u.+3.q:nail
            commands  [(produce-delete ~ parsed) commands]
          ==
    %drop-database
      =/  [parsed=* nail=edge]  |-
                                =/  nail  
                                    ~|  "drop database parse phase:  ".
                                        "{<`tape`(scag 100 q.q.command-nail)>}".
                                        " ..."
                                        %-  parse-drop-database
                                              [[1 1] q.q.command-nail]
                                [(wonk nail) nail]
      ~|  "drop database parse produce phase:  ".
          "{<`tape`(scag 100 q.q.command-nail)>} ..."
          ?@  parsed                                    :: name
            %=  $
              script    q.q.u.+3.q:nail
              commands  [(drop-database:ast %drop-database parsed %.n) commands]
            ==
          ?:  ?=([@ @] parsed)                          :: force name
            %=  $
              script    q.q.u.+3.q:nail
              commands  :-  (drop-database:ast %drop-database +.parsed %.y)
                            commands
            ==
          !!
    %drop-index
      =/  [parsed=* nail=edge]  |-
                                =/  nail  
                                    ~|  "drop index parse phase:  ".
                                        "{<`tape`(scag 100 q.q.command-nail)>}".
                                        " ..."
                                        %-  parse-drop-index
                                              [[1 1] q.q.command-nail]
                                [(wonk nail) nail]
      ~|  "drop index parse produce phase:  ".
          "{<`tape`(scag 100 q.q.command-nail)>} ..."
          %=  $
            script    q.q.u.+3.q:nail
            commands  :-  (drop-index:ast %drop-index -.parsed +.parsed ~)
                          commands
          ==
    %drop-namespace
      =/  [parsed=* nail=edge]  |-
                                =/  nail  
                                    ~|  "drop namespace parse phase:  ".
                                        "{<`tape`(scag 100 q.q.command-nail)>}".
                                        " ..."
                                        %-  parse-drop-namespace
                                              [[1 1] q.q.command-nail]
                                [(wonk nail) nail]
      ~|  "drop namespace parse produce phase:  ".
          "{<`tape`(scag 100 q.q.command-nail)>} ..."
          ?@  parsed                                    :: name
            %=  $
              script    q.q.u.+3.q:nail
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
              script    q.q.u.+3.q:nail
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
                                                %:  as-of-offset:ast
                                                      %as-of-offset
                                                      +>-.parsed
                                                      +>+<.parsed
                                                      ==
                                            ==
                    commands
            ==
          ?:  ?=([[%force @] %as-of *] parsed)          :: force name as of
            %=  $
              script    q.q.u.+3.q:nail
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
                                                %:  as-of-offset:ast
                                                      %as-of-offset
                                                      +>-.parsed
                                                      +>+<.parsed
                                                      ==
                                            ==
                    commands
            ==
          ?:  ?=([[@ @] %as-of *] parsed)                   :: name as of
            %=  $
              script    q.q.u.+3.q:nail
              commands
                ?:  =(%now +>.parsed)
                  :-  %:  drop-namespace:ast  %drop-namespace
                                              -<.parsed
                                              ->.parsed
                                              %.n
                                              ~
                                              ==
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
                                                %:  as-of-offset:ast  
                                                      %as-of-offset
                                                      +>-.parsed
                                                      +>+<.parsed
                                                      ==
                                            ==
                    commands
            ==
          ?:  ?=([[%force [@ @]] %as-of *] parsed)        :: force db.name as of
            %=  $
              script    q.q.u.+3.q:nail
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
                                                %:  as-of-offset:ast
                                                      %as-of-offset
                                                      +>-.parsed
                                                      +>+<.parsed
                                                      ==
                                            ==
                    commands
            ==
          ?:  ?=([%force @] parsed)                     :: force name
              %=  $
                script    q.q.u.+3.q:nail
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
              script    q.q.u.+3.q:nail
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
              script    q.q.u.+3.q:nail
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
      =/  [parsed=* nail=edge]  |-
                                =/  nail  
                                    ~|  "drop intabledex parse phase:  ".
                                        "{<`tape`(scag 100 q.q.command-nail)>}".
                                        " ..."
                                        %-  parse-drop-table-view
                                              [[1 1] q.q.command-nail]
                                [(wonk nail) nail]
      ~|  "drop table parse produce phase:  ".
          "{<`tape`(scag 100 q.q.command-nail)>} ..."
          ?:  ?=([[%force *] %as-of *] parsed) :: force table name as of
            %=  $
              script           q.q.u.+3.q:nail
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
              script           q.q.u.+3.q:nail
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
          ?:  ?=([@ @ @ @ @ @ @] parsed)           :: force qualified table name
            %=  $
              script    q.q.u.+3.q:nail
              commands  [(drop-table:ast %drop-table +.parsed %.y ~) commands]
            ==
          ?:  ?=([@ @ @ @ @ @] parsed)             :: qualified table name
            %=  $
              script    q.q.u.+3.q:nail
              commands  [(drop-table:ast %drop-table parsed %.n ~) commands]
            ==
          !!
    %drop-view
      =/  [parsed=* nail=edge]  |-
                                =/  nail  
                                    ~|  "drop view parse phase:  ".
                                        "{<`tape`(scag 100 q.q.command-nail)>}".
                                        " ..."
                                        %-  parse-drop-table-view
                                              [[1 1] q.q.command-nail]
                                [(wonk nail) nail]
      ~|  "drop view parse produce phase:  ".
          "{<`tape`(scag 100 q.q.command-nail)>} ..."
          ?:  ?=([@ @ @ @ @ @ @] parsed)                :: force qualified view
            %=  $
              script    q.q.u.+3.q:nail
              commands  [(drop-view:ast %drop-view +.parsed %.y) commands]
            ==
          ?:  ?=([@ @ @ @ @ @] parsed)                  :: qualified view
            %=  $
              script    q.q.u.+3.q:nail
              commands  [(drop-view:ast %drop-view parsed %.n) commands]
            ==
          !!
    %grant
      =/  [parsed=* nail=edge]  |-
                                =/  nail  
                                    ~|  "grant parse phase:  ".
                                        "{<`tape`(scag 100 q.q.command-nail)>}".
                                        " ..."
                                        %-  parse-grant
                                              [[1 1] q.q.command-nail]
                                [(wonk nail) nail]
      ~|  "grant parse produce phase:  ".
          "{<`tape`(scag 100 q.q.command-nail)>} ..."
          %=  $
            script    q.q.u.+3.q:nail
            commands  :-  %:  grant:ast  %grant
                                        -.parsed
                                        +<.parsed
                                        +>-.parsed
                                        +>+.parsed
                                        ==
                          commands
          ==
    %insert
      =/  [parsed=* nail=edge]  |-
                                =/  nail  
                                    ~|  "insert parse phase:  ".
                                        "{<`tape`(scag 100 q.q.command-nail)>}".
                                        " ..."
                                        ::~>  %bout.[0 %parse-insert]  
                                        %-  parse-insert
                                              [[1 1] q.q.command-nail]
                                [(wonk nail) nail]
      ~|  "insert parse produce phase:  ".
          "{<`tape`(scag 100 q.q.command-nail)>} ..."
      =/  ins
            ::~>  %bout.[0 %parse-produce-insert]  
            (produce-insert parsed)
      %=  $
        script    q.q.u.+3.q:nail
        commands  :-  (selection:ast %selection ~ [ins ~ ~])
                      commands
      ==
    %merge
      =/  [parsed=* nail=edge]  |-
                                =/  nail  
                                    ~|  "merge parse phase:  ".
                                        "{<`tape`(scag 100 q.q.command-nail)>}".
                                        " ..."
                                        %-  parse-merge
                                              [[1 1] q.q.command-nail]
                                [(wonk nail) nail]
      ~|  "merge parse produce phase:  ".
          "{<`tape`(scag 100 q.q.command-nail)>} ..."
          %=  $
            script    q.q.u.+3.q:nail 
            commands  :-  %^  selection:ast  %selection
                                             ~
                                             [(produce-merge parsed) ~ ~]
                          commands
          ==
    %query
      =/  [parsed=* nail=edge]  |-
                                =/  nail  
                                    ~|  "query parse phase:  ".
                                        "{<`tape`(scag 100 q.q.command-nail)>}".
                                        " ..."
                                        %-  parse-query
                                              [[1 1] q.q.command-nail]
                                ~&  "nail: {<nail>}"
                                [(wonk nail) nail]
      ~|  "query parse produce phase:  ".
          "{<`tape`(scag 100 q.q.command-nail)>} ..."
          %=  $
            script    q.q.u.+3.q:nail
            commands  :-  %^  selection:ast  %selection
                                             ~
                                             [(produce-query parsed) ~ ~]
                          commands
          ==
    %revoke
      =/  [parsed=* nail=edge]  |-
                                =/  nail  
                                    ~|  "revoke parse phase:  ".
                                        "{<`tape`(scag 100 q.q.command-nail)>}".
                                        " ..."
                                        %-  parse-revoke
                                              [[1 1] q.q.command-nail]
                                [(wonk nail) nail]
      ~|  "revoke parse produce phase:  ".
          "{<`tape`(scag 100 q.q.command-nail)>} ..."
          %=  $
            script    q.q.u.+3.q:nail
            commands  :-  %:  revoke:ast  %revoke
                                          -.parsed
                                          +<.parsed
                                          +>-.parsed
                                          +>+.parsed
                                          ==
                          commands
          ==
    %truncate-table
      =/  [parsed=* nail=edge]  |-
                                =/  nail  
                                    ~|  "truncate table parse phase:  ".
                                        "{<`tape`(scag 100 q.q.command-nail)>}".
                                        " ..."
                                        %-  parse-truncate-table
                                              [[1 1] q.q.command-nail]
                                [(wonk nail) nail]
      ~|  "truncate table parse produce phase:  ".
          "{<`tape`(scag 100 q.q.command-nail)>} ..."
          %=  $
            script    q.q.u.+3.q:nail
            commands
              :-  ?:  ?=(qualified-table:ast parsed)
                    %^  truncate-table:ast  %truncate-table
                                            parsed
                                            ~
                  ?:  ?=([qualified-table:ast %as-of [@ @ @]] parsed)
                    %^  truncate-table:ast  %truncate-table
                                            -.parsed
                                            :-  ~
                                                %^  as-of-offset:ast
                                                      %as-of-offset
                                                      +>-.parsed
                                                      +>+<.parsed
                  ?:  ?=([qualified-table:ast %as-of %now] parsed)
                    %^  truncate-table:ast  %truncate-table
                                            -.parsed
                                            ~
                  ?:  ?=([qualified-table:ast %as-of [@ @]] parsed)
                    %^  truncate-table:ast  %truncate-table
                                            -.parsed  
                                            [~ +>.parsed]
                  !!
                  commands
          ==
    %update
      =/  [parsed=* nail=edge]  |-
                                =/  nail  
                                    ~|  "update parse phase:  ".
                                        "{<`tape`(scag 100 q.q.command-nail)>}".
                                        " ..."
                                        (parse-update [[1 1] q.q.command-nail])
                                [(wonk nail) nail]
      %=  $
        script    q.q.u.+3.q:nail
        commands  :-  ~|  "update parse produce phase:  ".
                          "{<`tape`(scag 100 q.q.command-nail)>} ..."
                          (produce-update ~ parsed)
                      commands
      ==
    %with
      =/  [parsed=* nail=edge]  |-
                                =/  nail  
                                    ~|  "with parse phase:  ".
                                        "{<`tape`(scag 100 q.q.command-nail)>}".
                                        " ..."
                                        (parse-with [[1 1] q.q.command-nail])
                                [(wonk nail) nail]
      ~|  "with parse produce phase:  ".
          "{<`tape`(scag 100 q.q.command-nail)>} ..."
          ?:  =(+<.parsed %delete)
            %=  $
              script    q.q.u.+3.q:nail
              commands  :-  (produce-delete (produce-ctes -.parsed) +>.parsed)
                            commands
            ==
          ?:  =(+<.parsed %insert)
            %=  $
              script    q.q.u.+3.q:nail
              commands  :-  %:  selection:ast  %selection
                                              (produce-ctes -.parsed)
                                              [(produce-insert +>.parsed) ~ ~]
                                              ==        
                            commands
            ==
          ?:  =(+<.parsed %merge)
            %=  $
              script    q.q.u.+3.q:nail
              commands  :-  %:  selection:ast  %selection
                                              (produce-ctes -.parsed)
                                              [(produce-merge +>.parsed) ~ ~]
                                              ==
                            commands
            ==
          ?:  =(+<.parsed %query)
            %=  $
              script    q.q.u.+3.q:nail
              commands  :-  %:  selection:ast  %selection
                                              (produce-ctes -.parsed)
                                              [(produce-query +>.parsed) ~ ~]
                                              ==
                            commands
            ==
          ?:  =(+<.parsed %update)
            %=  $
              script    q.q.u.+3.q:nail
              commands  :-  (produce-update (produce-ctes -.parsed) +>.parsed)
                            commands
            ==
          !!
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
++  parse-ship  ~+  ;~(pfix sig fed:ag)
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
            (stag %table parse-qualified-3object)
            ==
++  parse-insert  ~+
  ;~  plug
    ;~  pose
      ;~  plug
        ;~(pfix whitespace parse-qualified-table)
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
        ;~(pfix whitespace parse-qualified-table)
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
    ;~(pose parse-scalars (easy ~)) :: this makes scalars definition optional
    ;~(pfix whitespace ;~(plug (cold %where (jester 'where')) parse-predicate))
    parse-group-by
    parse-select
    parse-order-by
    end-or-next-command
  ==
++  parse-query02  ~+
  ;~  plug
    parse-object-and-joins
    ;~(pose parse-scalars (easy ~)) :: this makes scalars definition optional
    ;~(pfix whitespace ;~(plug (cold %where (jester 'where')) parse-predicate))
    parse-group-by
    parse-select
    end-or-next-command
  ==
++  parse-query03  ~+
  ;~  plug
    parse-object-and-joins
    ;~(pose parse-scalars (easy ~)) :: this makes scalars definition optional
    ;~(pfix whitespace ;~(plug (cold %where (jester 'where')) parse-predicate))
    parse-select
    parse-order-by
    end-or-next-command
  ==
++  parse-query04  ~+
  ;~  plug
    parse-object-and-joins
    ;~(pose parse-scalars (easy ~)) :: this makes scalars definition optional
    ;~(pfix whitespace ;~(plug (cold %where (jester 'where')) parse-predicate))
    parse-select
    end-or-next-command
  ==
++  parse-query05  ~+
  ;~  plug
    parse-object-and-joins
    ;~(pose parse-scalars (easy ~)) :: this makes scalars definition optional
    parse-select
    parse-order-by
    end-or-next-command
  ==
++  parse-query06  ~+
  ;~  plug
    parse-object-and-joins
    ;~(pose parse-scalars (easy ~)) :: this makes scalars definition optional
    parse-select
    end-or-next-command
  ==
++  parse-query07  ~+
  ;~  plug
    parse-object-and-joins
    ;~(pose parse-scalars (easy ~)) :: this makes scalars definition optional
    parse-group-by
    parse-select
    parse-order-by
    end-or-next-command
  ==
++  parse-query08  ~+
  ;~  plug
    parse-object-and-joins
    ;~(pose parse-scalars (easy ~)) :: this makes scalars definition optional
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
                ;~  plug  parse-qualified-table
                          ;~(pfix whitespace ;~(pfix (jester 'as') parse-alias))
                          ==
                ==
      ;~  pfix  whitespace
                ;~  plug  (stag %query-row face-list)
                          ;~(pfix whitespace ;~(pfix (jester 'as') parse-alias))
                          ==
                ==
      ;~  pfix  whitespace
                ;~  plug  parse-qualified-table
                          (cold %as whitespace)
                          ;~(less merge-stop parse-alias)
                          ==
                ==
      ;~  pfix  whitespace
                ;~  plug  (stag %query-row face-list)
                          ;~(pfix whitespace ;~(less merge-stop parse-alias))
                          ==
                ==
      ;~(pfix whitespace parse-qualified-table)
      ;~(pfix whitespace (stag %query-row face-list))
    ==
    ;~  pose
        ;~  plug  (cold %using ;~(plug whitespace (jester 'using') whitespace))
                  ;~  plug
                    ;~(pose parse-qualified-table parse-alias)
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
                  ;~  plug  ;~(pose parse-qualified-table parse-alias)
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
                  parse-qualified-table
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
  ;~  plug
    sym
    ;~  pfix
      whitespace
      ;~  pfix
        (jest '=')
        ;~  pfix
            whitespace
            ;~  pose  parse-qualified-column
                      parse-value-literal
                      (cold %default (jester 'default'))
                      ==
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
  ;~  sfix
      ;~  pose
        ;~  plug
          ;~(pfix whitespace parse-qualified-table)
          parse-as-of
          (cold %set ;~(plug whitespace (jester 'set')))
          (more com update-column)
          ;~  pose
            ;~(pfix ;~(plug whitespace (jester 'where')) parse-predicate)
            (easy ~)
            ==
        ==
        ;~  plug
          ;~(pfix whitespace parse-qualified-table)
          (cold %set ;~(plug whitespace (jester 'set')))
          (more com update-column)
          ;~  pose
            ;~(pfix ;~(plug whitespace (jester 'where')) parse-predicate)
            (easy ~)
            ==
        ==
      ==
      end-or-next-command
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
            (stag %table parse-qualified-3object)
            ==
++  parse-truncate-table  ~+
  ;~  sfix
    ;~  pfix
          whitespace
          ;~  pose
              ;~(plug parse-qualified-table parse-as-of)
              parse-qualified-table
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
  =/  ctes  *(list cte:ast)
  |-
  ?~  a  (flop ctes)
  ?:  ?&(=(%cte -<.a) =(%as ->+<.a))
    %=  $
      a  +.a
      ctes  [(cte:ast %cte ->+>.a (produce-query ->-.a)) ctes]
    ==
  ~|('cannot produce ctes from parsed:  {<a>}' !!)
++  produce-delete
  |=  [ctes=(list cte:ast) a=*]
   ~+
  ^-  delete:ast
  ?>  ?=(qualified-table:ast -.a)
  ?:  ?=([* %where * %end-command ~] a)
    %:  delete:ast  %delete
                    ctes
                    -.a
                    ~
                    %+  qualify-predicate
                        (produce-predicate (predicate-list +>-.a))
                        -.a
                    ==
  ?:  ?=([* [%as-of %now] %where * %end-command ~] a)
    %:  delete:ast  %delete
                    ctes
                    -.a
                    ~
                    %+  qualify-predicate
                        (produce-predicate (predicate-list +>+<.a))
                        -.a
                    ==
  ?:  ?=([* [%as-of [@ @]] %where * %end-command ~] a)
    %:  delete:ast  %delete
                    ctes
                    -.a
                    [~ +<+.a]
                    %+  qualify-predicate
                        (produce-predicate (predicate-list +>+<.a))
                        -.a
                    ==
  ?:  ?=([* [%as-of *] %where * %end-command ~] a)
    %:  delete:ast  %delete
                    ctes
                    -.a
                    [~ (as-of-offset:ast %as-of-offset +<+<.a +<+>-.a)]
                    %+  qualify-predicate
                        (produce-predicate (predicate-list +>+<.a))
                        -.a
                    ==
  !!
::
++  qualify-predicate
  |=  [p=predicate:ast obj=qualified-table:ast]
  ~+
  ^-  predicate:ast
  ::
  |-
  ?~  p  ~
  p(n (qualify-pred-leaf n.p obj), l $(p l.p), r $(p r.p))
::
++  qualify-pred-leaf
  |=  [a=predicate-component:ast obj=qualified-table:ast]
  ~+
  ^-  predicate-component:ast
  ?.  ?&  ?=(qualified-column:ast a)
          =('UNKNOWN' database.qualifier.a)
          =('COLUMN-OR-CTE' namespace.qualifier.a)
          ==
    a
  %:  qualified-column:ast  %qualified-column
                            obj
                            name.a
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
  =/  profile  *(list [@t datum:ast])
  |-
  ?~  a  (flop profile)
  ?:  ?=([@ %qualified-column qualified-table:ast @ ~] -.a)
    %=  $
      profile  :-  :-  -<.a
                      %:  qualified-column:ast  %qualified-column
                                                `qualified-table:ast`->+<.a
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
  =/  matched                *(list matching:ast)
  =/  not-matched-by-target  *(list matching:ast)
  =/  not-matched-by-source  *(list matching:ast)
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
                      predicate=(produce-predicate (predicate-list -<+>.a))
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
                      predicate=(produce-predicate (predicate-list -<+>.a))
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
                                  (produce-predicate (predicate-list -<+>.a))
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
  =/  into          %.y
  =/  target-table  *(unit relation:ast)
  =/  new-table     *(unit relation:ast)
  =/  source-table  *(unit relation:ast)
  =/  predicate     *predicate:ast
  =/  matching      *matching-lists:ast
  |-
  ?~  a  ?:  ?&(=(target-table ~) =(source-table ~))
    ~|("target and source tables cannot both be pass through" !!)
  %:  merge:ast  %merge
                (need target-table)
                new-table
                (need source-table)
                predicate
                matched=matched.matching
                unmatched-by-target=not-target.matching
                unmatched-by-source=not-source.matching
                ~
                ==
  ?:  ?=(qualified-table:ast -.a)
    %=  $
      a  +.a
      target-table  `(relation:ast %relation -.a)
    ==
  ?:  ?=([%using @ %as @] -.a)
    %=  $
      a  +.a
      source-table
        :-  ~  %:  relation:ast  %relation
                                  %:  qualified-table:ast  %qualified-table
                                                            ~
                                                            default-database
                                                            'dbo'
                                                            +<.a
                                                            ==
                                   `+>+.a
                                   ==
    ==
  ?:  ?=([qualified-table:ast @] -.a)
    %=  $
      a  +.a
      target-table  `(make-query-object -.a)
    ==
  ?:  ?=([%using qualified-table:ast %as @] -.a)
    %=  $
      a  +.a
      source-table  `(relation:ast %relation ->-.a `->+>.a)
    ==
  ?:  =(%on -<.a)
    %=  $
      a  +.a
      predicate  (produce-predicate (predicate-list ->.a))
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
  =/  from       *(unit from:ast)
  =/  scalars    *(list scalar:ast)
  =/  predicate  *predicate:ast
  =/  group-by   *(list grouping-column:ast)
  =/  having     *predicate:ast
  =/  select     *(unit select:ast)
  =/  order-by   *(list ordering-column:ast)
  =/  alias-map  *(map @t qualified-table:ast)
  |-
  ?~  a  ~|("cannot parse query  {<a>}" !!)

  =.  alias-map  ?~   alias-map
                   ?~   from  ~
                   (mk-alias-map (need from))
                 alias-map 

  ?~  -.a                     $(a +.a) :: discard nulls from optional parsers
  ?:  =(-.a %query)           $(a +.a)
  ?:  =(-.a %end-command)    %:  query:ast
                                %query
                                ?~  from  ~
                                  `(finalize-predicates (need from) alias-map)
                                scalars
                                ?~  predicate  ~
                                  (finalize-predicate predicate alias-map)
                                group-by
                                having
                                (need select)
                                order-by
                                ==
  ?:  =(-<.a %scalars)        $(a +.a, scalars (produce-scalars -.a alias-map))
  ?:  =(-<.a %where)          %=  $
                                a          +.a
                                predicate  %-  produce-predicate
                                               (predicate-list ->.a)
                              ==
  ?:  =(-<.a %select)     $(a +.a, select `(produce-select ->.a from alias-map))
  ?:  =(-<.a %group-by)     $(a +.a, group-by (group-by-list ->.a))
  ?:  =(-<.a %order-by)     $(a +.a, order-by (order-by-list ->.a))
  ?:  =(-<-.a %relation)   $(a +.a, from `(produce-from -.a))
  ?:  =(-<-.a %query-row)   $(a +.a, from `(produce-from -.a))
  ?:  =(-<-<.a %relation)  $(a +.a, from `(produce-from -.a))

    ~&  "-.a:  {<-.a>}"

  ~|("cannot parse query  {<a>}" !!)
::
++  produce-from
  |=  a=*
  ~+
  ^-  from:ast
  =/  from-object=relation:ast
        ?:  ?=([%relation %qualified-table (unit @p) @ @ @ (unit @t)] -<.a)
          :-  %relation
              %:  qualified-table:ast  %qualified-table
                                        -<+>-.a
                                        -<+>+<.a
                                        -<+>+>-.a
                                        -<+>+>+<.a
                                        -<+>+>+>.a
                                        ==
        `relation:ast`(make-query-object ->.a)
  =/  from-as-of=(unit as-of:ast)
        ?:  =(%as-of-offset ->-.a)  [~ ;;(as-of-offset:ast ->.a)]
        ?:  =(~.da ->-.a)           [~ ;;(as-of:ast [%da ->+.a])]
        ?:  =(~.dr ->-.a)           [~ ;;(as-of:ast [%dr ->+.a])]
        ~
  =/  raw-joined-objects  +.a
  =/  joined-objects  *(list joined-object:ast)
  |-
  ?:  =(raw-joined-objects ~)
    (from:ast %from from-object from-as-of (flop joined-objects))
  =/  raw-join  -.raw-joined-objects
  ::cross join
  ?:  ?=  $:  %cross-join
              [%relation [%qualified-table (unit @p) @ @ @ (unit @t)]]
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
              [%relation [%qualified-table (unit @p) @ @ @ (unit @t)]]
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
                  [%relation [%qualified-table (unit @p) @ @ @ (unit @t)]]
                  [%da @]
                  ==
              raw-join
          ?=  $:  %cross-join
                  [%relation [%qualified-table (unit @p) @ @ @ (unit @t)]]
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
  ?:  ?|  ?=  [%join [%relation [%qualified-table (unit @p) @ @ @ (unit @t)]]]
              raw-join
          ?=  $:  %join
                  $:  [%relation [%qualified-table (unit @p) @ @ @ (unit @t)]]
                      %as-of-offset
                      *
                      ==
                  ==
              raw-join
          ?=  $:  %join
                  $:  [%relation [%qualified-table (unit @p) @ @ @ (unit @t)]]
                      [%da @]
                      ==
                  ==
              raw-join
          ?=  $:  %join
                  $:  [%relation [%qualified-table (unit @p) @ @ @ (unit @t)]]
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
                        $:  %relation
                            [%qualified-table (unit @p) @ @ @ (unit @t)]
                            ==
                        ==
                    raw-join
              (make-query-object +>.raw-join)
            (make-query-object +<+.raw-join)
            :: as-of
            ?:  ?=  $:  $:  %relation
                            [%qualified-table (unit @p) @ @ @ (unit @t)]
                            ==
                        %as-of-offset
                        *
                        ==
                    +.raw-join
              [~ ;;(as-of-offset:ast +>.raw-join)]
            ?:  ?=  $:  $:  %relation
                            [%qualified-table (unit @p) @ @ @ (unit @t)]
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
    ?:  ?|  ?=  $:  [%relation [%qualified-table (unit @p) @ @ @ (unit @t)]]
                    %as-of-offset
                    @
                    @
                    ==
                +<.raw-join
            ?=  $:  [%relation [%qualified-table (unit @p) @ @ @ (unit @t)]]
                    [%da @]
                    ==
                +<.raw-join
            ?=  $:  [%relation [%qualified-table (unit @p) @ @ @ (unit @t)]]
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
            (produce-predicate (predicate-list +>.raw-join))
            ==
            joined-objects
        raw-joined-objects    +.raw-joined-objects
      ==
    ?:  ?=  [[%relation [%qualified-table (unit @p) @ @ @ (unit @t)]] *]
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
            (produce-predicate (predicate-list +>.raw-join))
            ==
            joined-objects
        raw-joined-objects    +.raw-joined-objects
      ==
    ~|("join not supported: {<raw-join>}" !!)
  ~|("join type not supported: {<-.raw-join>}" !!)
::
++  finalize-predicates
  |=  [f=from:ast alias-map=(map @t qualified-table:ast)]
  ~+
  ^-  from:ast
  =/  jss  joins.f
  =/  js   *(list joined-object:ast)
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
                   (finalize-predicate predicate.j alias-map)
                   ==
             js
    jss  +.jss
  ==
:: todo:
:: - implement arithmetic
::   - add arithmetic to scalar fn
:: - add loop to check for scalar definitions with the same name; if found, crash
::   - modify scalar fn type so that it has a name and an alias, to allow for
::     mixed case scalar names
:: todo: refactor these gates
+$  alias-maps
  [table=(map @t qualified-table:ast) scalar=(map @t scalar-function:ast)]
++  finalize-scalar-param
  |=  [cooked-param=scalar-param aliases=alias-maps]
  ^-  datum-or-scalar:ast
  ?:  ?=([%literal *] cooked-param)
    %:(literal-value:ast %literal-value dime=+.cooked-param)
    :: - if the cooked-param is a one-item-qualifier, but there is a
    ::   scalar by the same name, then resolve the scalar
    :: - if the cooked-param is a one-item-qualifier, and ther isn't a
    ::   scalar by the same name, then pass it down to finalize qualifier
  ?:  ?=(unqualified-column:ast cooked-param)
    =/  maybe-scalar  (~(get by scalar.aliases) name.cooked-param)
    ?~  maybe-scalar
      (finalize-qualifier cooked-param table.aliases)
    (need maybe-scalar)
  :: - if the cooked-param is an unknown alias and there is a
  ::   scalar by the same name, then resolve the scalar
  :: - if the cooked-param is an unknown alias and there isn't
  ::   scalar by the same name, then cast to cte-alias
  ?:  ?=(unknown-alias cooked-param)
    =/  maybe-scalar  (~(get by scalar.aliases) name.cooked-param)
    ?~  maybe-scalar
      (cte-alias:ast %cte-alias name.cooked-param)
    (need maybe-scalar)
  (finalize-qualifier cooked-param table.aliases)
++  finalize-if
  |=  [cooked-if=if-then-else-helper aliases=alias-maps]
  ^-  if-then-else:ast
  =/  finalized-then
    (finalize-scalar-param then.cooked-if aliases)
  =/  finalized-else
    (finalize-scalar-param else.cooked-if aliases)
  %:  if-then-else:ast
    %if-then-else
    if=if.cooked-if
    then=finalized-then
    else=finalized-else
  ==
++  finalize-case
  |=  [cooked-case=case-helper aliases=alias-maps]
  ^-  case:ast
  =/  finalized-target
    (finalize-scalar-param target.cooked-case aliases)
  =/  finalized-cases 
    |-
    ^-  (list case-when-then:ast)
    ?~  cases.cooked-case
      ~
    =/  finalized-case-when-then
      :+  %case-when-then
         when.i.cases.cooked-case
      (finalize-scalar-param then.i.cases.cooked-case aliases)
    [finalized-case-when-then $(cases.cooked-case t.cases.cooked-case)]
  =/  finalized-else
    %+  biff
      else.cooked-case
    |=  else=scalar-param
    (some (finalize-scalar-param else aliases))
  %:  case:ast
    %case
    target=finalized-target
    cases=finalized-cases
    else=finalized-else
  ==
++  finalize-coalesce
  |=  [cooked-coalesce=coalesce-helper aliases=alias-maps]
  ^-  coalesce:ast
  =/  finalized-data
    %+  turn
      data.cooked-coalesce
    |=  param=scalar-param
    (finalize-scalar-param param aliases)
  %:  coalesce:ast
    %coalesce
    data=finalized-data
  ==
++  produce-scalar-fn
  |=  [fn-name=@tas raw-scalar-body=* aliases=alias-maps]
  ^-  scalar-function:ast
  ?:  =(%coalesce fn-name)
    =/  cooked-coalesce  (cook-coalesce raw-scalar-body)
    =/  finalized-coalesce  (finalize-coalesce cooked-coalesce aliases)
      finalized-coalesce
  ?:  =(%if fn-name)
    =/  cooked-if  (cook-if raw-scalar-body)
    =/  finalized-if  (finalize-if cooked-if aliases)
      finalized-if
  ?:  =(%case fn-name)
     =/  cooked-case  (cook-case-body raw-scalar-body)
     =/  finalized-case  (finalize-case cooked-case aliases)
       finalized-case
   ::  nullary builtin functions (no parameters, cast directly)
   ?:  =(%getdate fn-name)
     ^-  getdate:ast
       [%getdate]
   ?:  =(%sysdatetimeoffset fn-name)
     ^-  sysdatetimeoffset:ast
       [%sysdatetimeoffset]
   ::  unary builtin functions
   ?:  =(%day fn-name)
     ^-  day:ast
     :*
       %day
       (cook-builtin-fn-parameter raw-scalar-body)
     ==
   ?:  =(%month fn-name)
     ^-  month:ast
     :*
       %month
       (cook-builtin-fn-parameter raw-scalar-body)
     ==
   ?:  =(%year fn-name)
     ^-  year:ast
     :*
       %year
       (cook-builtin-fn-parameter raw-scalar-body)
     ==
   ?:  =(%abs fn-name)
     ^-  abs:ast
     :*
       %abs
       (cook-builtin-fn-parameter raw-scalar-body)
     ==
   ?:  =(%floor fn-name)
     ^-  floor:ast
     :*
       %floor
       (cook-builtin-fn-parameter raw-scalar-body)
     ==
   ?:  =(%ceiling fn-name)
     ^-  ceiling:ast
     :*
       %ceiling
       (cook-builtin-fn-parameter raw-scalar-body)
     ==
   ?:  =(%sign fn-name)
     ^-  sign:ast
     :*
       %sign
       (cook-builtin-fn-parameter raw-scalar-body)
     ==
   ?:  =(%sqrt fn-name)
     ^-  sqrt:ast
     :*
       %sqrt
       (cook-builtin-fn-parameter raw-scalar-body)
     ==
   ?:  =(%len fn-name)
     ^-  len:ast
     :*
       %len
       (cook-builtin-fn-parameter raw-scalar-body)
     ==
   ::  binary builtin functions
   ?:  =(%log fn-name)
     ^-  log:ast
     ?:  ?=([[@ @] *] raw-scalar-body)
       :*
         %log
         (cook-builtin-fn-parameter -.raw-scalar-body)
         (cook-builtin-fn-optional-parameter +.raw-scalar-body)
       ==
     :*
       %log
       (cook-builtin-fn-parameter raw-scalar-body)
       ~
     ==
   ?:  =(%power fn-name)
     ^-  power:ast
     :*
       %power
       (cook-builtin-fn-parameter -.raw-scalar-body)
       (cook-builtin-fn-parameter +.raw-scalar-body)
     ==
   ?:  =(%left fn-name)
     ^-  left:ast
     :*
       %left
       (cook-builtin-fn-parameter -.raw-scalar-body)
       (cook-builtin-fn-parameter +.raw-scalar-body)
     ==
   ?:  =(%right fn-name)
     ^-  right:ast
     :*
       %right
       (cook-builtin-fn-parameter -.raw-scalar-body)
       (cook-builtin-fn-parameter +.raw-scalar-body)
     ==
   ?:  =(%trim fn-name)
     ^-  trim:ast
     ?:  ?=([[@ @] *] raw-scalar-body)
       :*
         %trim
         (cook-builtin-fn-optional-parameter -.raw-scalar-body)
         (cook-builtin-fn-parameter +.raw-scalar-body)
       ==
     :*
       %trim
       ~
       (cook-builtin-fn-parameter raw-scalar-body)
     ==
   ::  ternary builtin functions
   ?:  =(%round fn-name)
     ^-  round:ast
     ?:  ?=([[@ @] * *] raw-scalar-body)
       :*
         %round
         (cook-builtin-fn-parameter -.raw-scalar-body)
         (cook-builtin-fn-parameter +<.raw-scalar-body)
         (cook-builtin-fn-optional-parameter +>.raw-scalar-body)
       ==
     ?:  ?=([[@ @] *] raw-scalar-body)
       :*
         %round
         (cook-builtin-fn-parameter -.raw-scalar-body)
         (cook-builtin-fn-parameter +.raw-scalar-body)
         ~
       ==
     !!
   ?:  =(%substring fn-name)
     ^-  substring:ast
     :*
       %substring
       (cook-builtin-fn-parameter -.raw-scalar-body)
       (cook-builtin-fn-parameter +<.raw-scalar-body)
       (cook-builtin-fn-parameter +>.raw-scalar-body)
     ==
   ::  n-ary builtin functions
   ?:  =(%concat fn-name)
     =/  cooked-params=(list literal-value:ast)
       |-
       ?~  raw-scalar-body
         ~
       :-  (cook-builtin-fn-parameter -.raw-scalar-body)
       $(raw-scalar-body +.raw-scalar-body)
     ^-  concat:ast
       [%concat cooked-params]
   ~|  "produce-scalar: scalar {<fn-name>} not implemented"  !!
++  produce-scalars
  |=  [raw-scalars=* table-aliases=(map @t qualified-table:ast)]
  ^-  (list scalar:ast)
  =/  scalars  +.raw-scalars
  =/  scalar-map  *(map @t scalar-function:ast)
  =/  finalized-scalars
    ~|  "produce-scalars: no scalars found: {<raw-scalars>}"
    |-
    ^-  (list scalar:ast)
    ?~  scalars
      ~
    =/  parsed-scalar  -.scalars
    =/  scalar-alias  (cook-scalar-alias -.parsed-scalar)
    =/  fn-name  (@tas +<.parsed-scalar)
    =/  raw-body  +>.parsed-scalar 
    =/  scalar-function
      (produce-scalar-fn fn-name raw-body [table-aliases scalar-map])
    =/  scalar  [%scalar scalar=scalar-function alias=scalar-alias]
      :-  scalar
      %=  $
        scalar-map  (~(put by scalar-map) scalar-alias scalar-function)
        scalars     +.scalars
      ==
  finalized-scalars
++  finalize-predicate
  |=  [p=predicate:ast alias-map=(map @t qualified-table:ast)]
  ~+
  ^-  predicate:ast
  ::
  |-
  ?~  p  ~
  p(n (finalize-leaf n.p alias-map), l $(p l.p), r $(p r.p))
::
++  finalize-leaf
  |=  [a=predicate-component:ast alias-map=(map @t qualified-table:ast)]
  ~+
  ^-  predicate-component:ast
  ?-  a
    ops-and-conjs:ast
      a
    qualified-column:ast
      ?:  ?&  =('UNKNOWN' database.qualifier.a)
              =('COLUMN-OR-CTE' namespace.qualifier.a)
              ==
        %^  unqualified-column:ast  %unqualified-column
                                    name.a
                                    alias.a
      ?:  ?&  =('UNKNOWN' database.qualifier.a)
              =('COLUMN' namespace.qualifier.a)
              ==
        %:  qualified-column:ast  %qualified-column
                                  %-  ~(got by alias-map)
                                      (crip (cass (trip name.qualifier.a)))
                                  name.a
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
  |=  [=qualified-column:ast alias-map=(map @t qualified-table:ast)]
  ~+
  ^-  selected-all-object:ast
  =/  object  %-  ~(get by alias-map)
                  (crip (cass (trip name.qualifier.qualified-column)))
  ?~  object
    %+  selected-all-object:ast  %all-object
                                 %:  qualified-table:ast
                                      %qualified-table
                                      ~ 
                                      default-database
                                      %dbo
                                      name.qualifier.qualified-column
                                      ==
  (selected-all-object:ast %all-object (need object))
::
++  mk-qualified-table
  |=  [a=qualified-column:ast alias-map=(map @t qualified-table:ast)]
  ~+
  ^-  qualified-column:ast
  =/  object  %-  ~(get by alias-map)
                  (crip (cass (trip name.qualifier.a)))
  ?~  object
    %:  qualified-column:ast  %qualified-column
                              %:  qualified-table:ast
                                  %qualified-table
                                  ship.qualifier.a
                                  default-database
                                  %dbo
                                  name.qualifier.a
                                  alias.qualifier.a
                                  ==
                              name.a
                              alias.a
                              ==
  %:  qualified-column:ast
      %qualified-column
      (need object)
      name.a
      alias.a
      ==
::
++  finalize-select
  |=  [s=(list selected-column:ast) alias-map=(map @t qualified-table:ast)]
  ~+
  ^-  (list selected-column:ast)
  =/  s-out  *(list selected-column:ast)
  ::
  |-
  ?~  s  (flop s-out)
  %=  $
    s      t.s
    s-out  :-  ?.  ?=(qualified-column:ast i.s)
                 i.s
               ?:  ?&  =('UNKNOWN' database.qualifier.i.s)
                       =('COLUMN' namespace.qualifier.i.s)
                       ==
                  (mk-qualified-table i.s alias-map)
               ?:  ?&  =('UNKNOWN' database.qualifier.i.s)
                       =('COLUMN-OR-CTE' namespace.qualifier.i.s)
                       =('ALL' name.i.s)
                       ==
                  (mk-all-object i.s alias-map) 
               ?:  ?&  =('ALL' name.i.s)
                       !=(name.qualifier.i.s name.i.s)
                       ==
                  %+  selected-all-object:ast
                      %all-object
                      qualifier.i.s
               ?:  ?&  =('UNKNOWN' database.qualifier.i.s)
                       =('COLUMN-OR-CTE' namespace.qualifier.i.s)
                       ==
                  %^  unqualified-column:ast  %unqualified-column
                                              name.i.s
                                              alias.i.s
               i.s
               ::
               s-out
  ==
::
::  +mk-alias-map:  from:ast -> (map @t qualified-table:ast)
::
:: map relation alias to qualified-table
:: if db of qualified-table is default db
:: and namespace is 'dbo'
::
++  mk-alias-map
  |=  f=from:ast
  ~+
  ^-  (map @t qualified-table:ast)
  =/  n  (mk-alias-map-joins ~ joins.f)
  ?.  ?=(qualified-table:ast object.object.f)
    ~|("not implemented {<object.f>}" !!)
  ?~  alias.object.object.f
    n
  %+  ~(put by n)  (crip (cass (trip (need alias.object.object.f))))
                   object.object.f
::
++  mk-alias-map-joins
  |=  [m=(map @t qualified-table:ast) js=(list joined-object:ast)]
  ~+
  ^-  (map @t qualified-table:ast)
  |-
  ?~  js  m
  =/  j=joined-object:ast  -.js
  ?.  ?=(qualified-table:ast object.object.j)
    ~|("not implemented {<object.j>}" !!)
  %=  $
    m   ?~  alias.object.object.j  m
        %+  ~(put by m)  (crip (cass (trip (need alias.object.object.j))))
                         object.object.j
    js  +.js
  ==
::
::  +mk-obj-name-map:  from:ast -> (map @t qualified-table:ast)
::
:: map relation object name to qualified-table
:: if db of qualified-table is default db
:: and namespace is 'dbo'
::
++  mk-obj-name-map
  |=  f=from:ast
  ~+
  ^-  (map @t qualified-table:ast)
  =/  n  (mk-obj-name-map-joins ~ joins.f)
  ?.  ?=(qualified-table:ast object.object.f)
    ~|("not implemented {<object.f>}" !!)
  %+  ~(put by n)  (crip (cass (trip name.object.object.f)))
                   object.object.f
::
++  mk-obj-name-map-joins
  |=  [m=(map @t qualified-table:ast) js=(list joined-object:ast)]
  ~+
  ^-  (map @t qualified-table:ast)
  |-
  ?~  js  m
  =/  j=joined-object:ast  -.js
  ?.  ?=(qualified-table:ast object.object.j)
    ~|("not implemented {<object.j>}" !!)
  %=  $
    m   %+  ~(put by m)  (crip (cass (trip name.object.object.j)))
                         object.object.j
    js  +.js
  ==
++  produce-select
  |=  [a=* f=(unit from:ast) alias-map=(map @t qualified-table:ast)]
  ^-  select:ast
  =/  top      *(unit @ud)
  =/  columns  *(list selected-column:ast)
  |-
    ~|  "cannot parse select -.a:  {<-.a>}"
    ?~  a
      ?~  columns  ~|('no columns selected' !!)
      ?~  f
        (select:ast %select top (flop columns))
      (select:ast %select top (finalize-select (flop columns) alias-map))
    ?@  -.a
      ?+  -.a  ~|('some other select atom' !!)
      %top       ?>  ?=(@ud +<.a)  $(top `+<.a, a +>.a)
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
    ?:  ?=([%all-columns %qualified-table (unit @p) @ @ @ (unit @t)] -.a)
      %=  $
        columns
          :-  %+  selected-all-object:ast
                    %all-object
                    %:  qualified-table:ast  %qualified-table
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
                %:  qualified-table:ast
                  %qualified-table
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
  |=  [ctes=(list cte:ast) a=*]
  ~+
  ^-  update:ast
  =/  table=qualified-table:ast  ?>(?=(qualified-table:ast -.a) -.a)
  =/  b  +.a
  ?:  ?=([%set * ~] b)
    %:  update:ast  %update
                    ctes
                    table
                    ~
                    (produce-column-sets table +<.b)
                    ~
                    ==
  ?:  ?=([[%as-of %now] %set * ~] b)
    %:  update:ast  %update
                    ctes
                    table
                    ~
                    (produce-column-sets table +>-.b)
                    ~
                    ==
  ?:  ?=([[%as-of @ @] %set * ~] b)
    %:  update:ast  %update
                    ctes
                    table
                    [~ ->.b]
                    (produce-column-sets table +>-.b)
                    ~
                    ==
  ?:  ?=([[%as-of *] %set * ~] b)
    %:  update:ast  %update
                    ctes
                    table
                    [~ (as-of-offset:ast %as-of-offset ->-.b ->+<.b)]
                    (produce-column-sets table +>-.b)
                    ~
                    ==                    
  ?:  ?=([[%as-of %now] %set * *] b)
    %:  update:ast  %update
                    ctes
                    table
                    ~
                    (produce-column-sets table +>-.b)
                    %+  qualify-predicate
                        (produce-predicate (predicate-list +>+.b))
                        table
                    ==
  ?:  ?=([[%as-of @ @] %set * *] b)
    %:  update:ast  %update
                    ctes
                    table
                    [~ ->.b]
                    (produce-column-sets table +>-.b)
                    %+  qualify-predicate
                        (produce-predicate (predicate-list +>+.b))
                        table
                    ==
  ?:  ?=([[%as-of @ @ @] %set * *] b)
    %:  update:ast  %update
                    ctes
                    table
                    [~ (as-of-offset:ast %as-of-offset ->-.b ->+<.b)]
                    (produce-column-sets table +>-.b)
                    %+  qualify-predicate
                        (produce-predicate (predicate-list +>+.b))
                        table
                    ==
  %:  update:ast  %update
                  ctes
                  table
                  ~
                  (produce-column-sets table +<.b)
                  %+  qualify-predicate
                      (produce-predicate (predicate-list +>.b))
                      table
                  ==
::
++  produce-column-sets
  |=  [table=qualified-table:ast a=*]
  ~+
  ^-  [(list qualified-column:ast) (list value-or-default:ast)]
  =/  columns  *(list qualified-column:ast)
  =/  values   *(list value-or-default:ast)
  |-
  ?:  =(a ~)
    [columns values]
  =/  b  -.a
  %=  $
      columns  :-  %:  qualified-column:ast  %qualified-column
                                             table
                                             -.b
                                             ~
                                             ==
                   columns
      values   ?.  ?=(qualified-column:ast +.b)
                 [;;(value-or-default:ast +.b) values]
               ?:  ?&  =('UNKNOWN' database.qualifier.+.b)
                      =('COLUMN-OR-CTE' namespace.qualifier.+.b)
                      ==
                 :-  (unqualified-column:ast %unqualified-column name.+.b ~)
                     values
               [;;(value-or-default:ast +.b) values]
      a        +.a
  ==
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
    (qualified-table:ast %qualified-table ~ default-database 'dbo' a ~)
  (qualified-table:ast %qualified-table ~ default-database -.a +.a ~)
::
::  +cook-qualified-3object: database.namespace.object-name
++  cook-qualified-3object
  |=  a=*
  ~+
  ?:  ?=([@ @ @] a)                                 :: db.ns.name
    (qualified-table:ast %qualified-table ~ -.a +<.a +>.a ~)
  ?:  ?=([@ @ @ @] a)                               :: db..name
    (qualified-table:ast %qualified-table ~ -.a 'dbo' +>+.a ~)
  ?:  ?=([@ @] a)                                   :: ns.name
    (qualified-table:ast %qualified-table ~ default-database -.a +.a ~)
  ?@  a                                             :: name
    (qualified-table:ast %qualified-table ~ default-database 'dbo' a ~)
  ~|("cannot parse qualified-table  {<a>}" !!)
::
::  +cook-qualified-table: @p.database.namespace.object-name
++  cook-qualified-table
  |=  a=*
  ~+
  ?:  ?=([@ @ @ @] a)
    ?:  =(+<.a '.')
      (qualified-table:ast %qualified-table ~ -.a 'dbo' +>+.a ~)  :: db..name
    :: ~firsub.db.ns.name
    (qualified-table:ast %qualified-table `-.a +<.a +>-.a +>+.a ~)
  ?:  ?=([@ @ @ @ @ @] a)                           :: ~firsub.db..name
    (qualified-table:ast %qualified-table `-.a +>-.a 'dbo' +>+>+.a ~)
  ?:  ?=([@ @ @] a)
    (qualified-table:ast %qualified-table ~ -.a +<.a +>.a ~)  :: db.ns.name
  ?:  ?=([@ @] a)                                   :: ns.name
    (qualified-table:ast %qualified-table ~ default-database -.a +.a ~)
  ?@  a                                             :: name
    (qualified-table:ast %qualified-table ~ default-database 'dbo' a ~)
  ~|("cannot parse qualified-table  {<a>}" !!)
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
++  parse-qualified-table  ~+
  %:  cook  cook-qualified-table
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
    (cold %default (jester 'default'))  :: \/ to do: inside-out
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
  =/  literal-list=tape  ~
  |-
  ?:  =(a ~)
    (value-literals:ast %value-literals literal-type (crip literal-list))
  ?:  =(-<.a literal-type)
    ?:  =(literal-list ~)
      $(a +.a, literal-list (a-co:co ->.a))
    $(a +.a, literal-list (weld (weld (a-co:co ->.a) ";") literal-list))
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
:: this version of parse-scalar-param sidesteps the unknown column/cte issue in
:: qualified columns by parsing qualifiers into their own types
:: <lowercase-name> unqualified-column
:: <mixedcase-name> alias
++  parse-scalar-param  ~+ 
  ;~  pose
    ;~(pose ;~(pfix whitespace parse-qualifier) parse-qualifier)
    %+  stag
      %alias
    ;~(pose ;~(pfix whitespace parse-scalar-alias) parse-scalar-alias)
    %+  stag
      %literal
    ;~(pose ;~(pfix whitespace parse-value-literal) parse-value-literal)
  ==
++  parse-datum-for-predicate  ~+
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
                ;~  plug
                  ;~(sfix parse-alias pal)
                  ;~(sfix get-datum-for-predicate par)
                ==
              ==
    ==
    %:  cook  cook-aggregate
              ;~  plug
                ;~(sfix parse-alias pal)
                ;~(sfix get-datum-for-predicate par)
              ==
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
                ;~  plug
                  ;~(sfix parse-alias pal)
                  ;~(sfix get-scalar-param par)
                ==
              ==
    ==
    %:  cook  cook-selected-aggregate
              ;~  plug
                ;~(sfix parse-alias pal)
                ;~(sfix get-scalar-param par)
              ==
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
  |=  a=*  ::a=[table=qualified-table:ast f-keys=*]
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
                                  %:  qualified-table:ast  %qualified-table
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
                              %:  qualified-table:ast  %qualified-table
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
    ;~(plug (jester 'scalars') whitespace)
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
      parse-qualified-table
      parse-as-of
      ;~(pfix whitespace ;~(pfix (jester 'as') parse-alias)) 
    ==
    ;~  plug                :: <alias> <as-of-time>
      parse-qualified-table
      parse-as-of
      ;~(pfix whitespace ;~(less join-stop parse-alias))
    ==
    ;~  plug                :: <as-of-time>
      parse-qualified-table
      parse-as-of
    == 
    ;~  plug                  :: AS <alias>
      parse-qualified-table
      ;~(pfix whitespace ;~(pfix (jester 'as') parse-alias))
    ==
    ;~  plug                  :: <alias>
      parse-qualified-table
      ;~(pfix whitespace ;~(less join-stop parse-alias))
    ==
    parse-qualified-table    :: no alias, no as-of
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
  ^-  $?  relation:ast
          [relation:ast as-of-offset:ast]
          [relation:ast as-of:ast]
          ==
   ?:  ?=([[%qualified-table (unit @p) @ @ @ (unit @t)] @] parsed)
    %+  relation:ast  %relation
                       :*  %qualified-table
                           ->-.parsed
                           ->+<.parsed
                           ->+>-.parsed
                           ->+>+<.parsed
                           `+.parsed
                           ==
  ?:  ?=([[%qualified-table (unit @p) @ @ @ (unit @t)]] parsed)
    (relation:ast %relation parsed)
  ::
  ?:  ?=([[%qualified-table (unit @p) @ @ @ (unit @t)] %as-of %now] parsed)
    :-  (relation:ast %relation -.parsed)
        (as-of-offset:ast %as-of-offset 0 %seconds)
  ?:  ?=([[%qualified-table (unit @p) @ @ @ (unit @t)] [%as-of %now] @] parsed)
    :-  %+  relation:ast  %relation
                           :*  %qualified-table
                               ->-.parsed
                               ->+<.parsed
                               ->+>-.parsed
                               ->+>+<.parsed
                               `+>.parsed
                               ==
        (as-of-offset:ast %as-of-offset 0 %seconds)
  ::
  ?:  ?=  [[%qualified-table (unit @p) @ @ @ (unit @t)] [%as-of @ @ %ago]]
          parsed
    :-  (relation:ast %relation -.parsed)
        (as-of-offset:ast %as-of-offset +>-.parsed +>+<.parsed)
  ?:  ?=  [[%qualified-table (unit @p) @ @ @ (unit @t)] [%as-of @ @ %ago] @]
          parsed
    :-  %+  relation:ast  %relation
                           :*  %qualified-table
                               ->-.parsed
                               ->+<.parsed
                               ->+>-.parsed
                               ->+>+<.parsed
                               `+>.parsed
                               ==
        (as-of-offset:ast %as-of-offset +<+<.parsed +<+>-.parsed)
  ::
  ?:  ?=([[%qualified-table (unit @p) @ @ @ (unit @t)] [%as-of @ @]] parsed)
    :-  (relation:ast %relation -.parsed)
        ;;(as-of:ast [+>-.parsed +>+.parsed])
  ?:  ?=([[%qualified-table (unit @p) @ @ @ (unit @t)] [%as-of @ @] @] parsed)
    :-  %+  relation:ast  %relation
                           :*  %qualified-table
                               ->-.parsed
                               ->+<.parsed
                               ->+>-.parsed
                               ->+>+<.parsed
                               `+>.parsed
                               ==
        ;;(as-of:ast [+<+<.parsed +<+>.parsed])
  ::
  ?:  =(%query-row -.parsed)  ;;(relation:ast parsed)
  ~|("cannot parse query-object  {<parsed>}" !!)
::
++  parse-query-object  ~+
  ;~  pfix
    whitespace
    (cook build-query-object query-object)
  ==
++  parse-cross-join-obj  ~+
  ;~(plug parse-cross-join-type parse-query-object)
++  parse-natural-join  ~+
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
  ~+
  ^-  relation:ast
  ?:  ?=(qualified-table:ast a)
    (relation:ast %relation a)
  ?:  ?=(qualified-table:ast -.a)
    ?~  +.a  (relation:ast %relation -.a)
    ?:  ?=((unit @t) +.a)
      (relation:ast %relation -.a +.a)
    %+  relation:ast  %relation
                       [%qualified-table ->-.a ->+<.a ->+>-.a ->+>+<.a `+.a]
  ?:  ?=([@ @] a)
    %+  relation:ast
      %relation
      %:  qualified-table:ast  %qualified-table
                                ~
                                'UNKNOWN'
                                'COLUMN-OR-CTE'
                                -.a
                                `+.a
                                ==
  ::  %query-row not implemented
  =/  columns  *(list @t)
  =/  b  ?:  ?=([%query-row * @] a)  +<.a
    ?:  =(%query-row -.a)  +.a
    ?:  =(%query-row -<.a)  ->.a  -.a
  =/  alias  ?:  ?=([%query-row * @] a)  +>.a
    ?:  =(%query-row -.a)  ~  +.a
  |-
  ?~  b
    ?~  alias
      %:  relation:ast
        %relation
        object=(query-row:ast %query-row (flop columns))
        ~
      ==
    %:  relation:ast
      %relation
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
      (qualified-table:ast %qualified-table `-.a +<.a +>-.a +>+<.a ~)
      +>+>.a
      ~
    ==
  ?:  ?=([@ @ @ @ @ @] a) :: @p.db..object.column
    %:  qualified-column:ast
      %qualified-column
      (qualified-table:ast %qualified-table `-.a +<.a 'dbo' +>+>-.a ~)
      +>+>+.a
      ~
    ==
  ?:  ?=([@ @ @ @] a)   :: db..object.column; db.ns.object.column
    ?:  =(+<.a '.')
      %:  qualified-column:ast
        %qualified-column
        (qualified-table:ast %qualified-table ~ -.a 'dbo' +>-.a ~)
        +>+.a
        ~
      ==
    %:  qualified-column:ast
      %qualified-column
      (qualified-table:ast %qualified-table ~ -.a +<.a +>-.a ~)
      +>+.a
      ~
    ==
  ?:  ?=([@ @ @] a)     :: ns.object.column
    %:  qualified-column:ast
      %qualified-column
      (qualified-table:ast %qualified-table ~ default-database -.a +<.a ~)
      +>.a
      ~
    ==
  ?:  ?=([@ @] a)       :: something.column (could be table, table alias or cte)
    %:  qualified-column:ast
      %qualified-column
      (qualified-table:ast %qualified-table ~ 'UNKNOWN' 'COLUMN' -.a ~)
      +.a
      ~
    ==
  ?@  a                 :: column, column alias, or cte
    %:  qualified-column:ast
      %qualified-column
      (qualified-table:ast %qualified-table ~ 'UNKNOWN' 'COLUMN-OR-CTE' a ~)
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
++  parse-qualifier  ~+
  :: to do: (someday) parse 4 & 5 directly into qualified-column
  ::        clean-up parse-qualifier, parse-qualified-column, parse-column,
  ::        cook-qualified-column
  ::        can probably be one ;~ pose
  ;~  pose
    ::
    ::  five-item qualified-column
    ::  @p.<database>.<namespace>.<table-or-view>.<column-name>
    ;~((glue dot) parse-ship sym sym sym sym)
    ::  @p.<database>..<table-or-view>.<column-name>
    ;~  plug
      parse-ship 
      ;~(pfix dot sym)
      (cold ~ dot)
      ;~(pfix dot sym)
      ;~(pfix dot sym)
    ==
    ::  four-item qualified-column
    ::  <database>.<namespace>.<table-or-view>.<column-name>
    ;~((glue dot) sym sym sym sym)
    ::  <database>..<table-or-view>.<column-name>
    ;~(plug sym (cold ~ dot) ;~(pfix dot sym) ;~(pfix dot sym))
    ::  <namespace>.<table-or-view>.<column-name>
    (stag ~ ;~((glue dot) sym sym sym))
    ::
    ::  two-item-qualifier
    ::  <alias>.<column-name>
    ;~(plug mixed-case-symbol ;~(pfix dot sym))
    ::
    ::  one-item-qualifier
    ::  <column-name>
    sym
    ::
  ==
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
    (cold %not ;~(plug (jester 'not') whitespace))
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
  =/  new-list  *(list raw-pred-cmpnt)
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
    parse-datum-for-predicate
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
    unary-op:ast     :: ?(%not %not-exists %exists)
      ?~  p.r
        [-.q.r (produce-predicate `(list raw-pred-cmpnt)`+.q.r) ~]
      ?:  ?=(unary-op:ast -.p.r)
        [-.p.r (produce-predicate q.r) ~]
      ~|("unknown predicate node {<-.p.r>}" !!)
    binary-op:ast    :: ?(%eq inequality-op %equiv %not-equiv %in)
      ?:  ?=(unary-op:ast -.p.r)
        ?:  ?=(%not -.p.r)
          [-.p.r (produce-predicate +.parsed) ~]
        ~|("malformed predicate {<-.p.r>}" !!)
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
::  parsed list is a predicate leaf
++  pred-leaf
  |=  parsed=(list raw-pred-cmpnt)
  ~+
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
::    +pred-folder  [raw-pred-cmpnt pred-folder-state] -> pred-folder-state
++  pred-folder
  |=  [pred-comp=raw-pred-cmpnt state=pred-folder-state]
  ~+
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
    unary-op:ast     :: ?(%not %exists %not-exists)
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
::
::    +split-at: [(list T) index:@] -> [(list T) (list T)]
++  split-at
  |*  [p=(list) i=@]
  ~+
  [(scag i p) (slag i p)]
::
::    +fold: [(list T1) state:T2 folder:$-([T1 T2] T2)] -> T2
++  fold
  |=  [a=(list raw-pred-cmpnt) b=pred-folder-state c=_pred-folder]
  ~+
  |-  ^+  b
  ?~  a  b
  $(a t.a, b (c i.a b))
++  update-pred-folder-state
  |=  [pred-comp=raw-pred-cmpnt state=pred-folder-state]
  ~+
  ^-  pred-folder-state
  :*  (dec displ.state)
      level.state
      `pred-comp
      (dec displ.state)
      the-list.state
      ==
++  advance-pred-folder-state
  |=  state=pred-folder-state
  ~+
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
::  helper wet gates for scalar functions
::
++  parse-nullary-scalar-fn
  |*  [fn-name=@tas]
  ;~  plug
    (cold fn-name (jester fn-name))
    ;~  pfix
      whitespace 
      (ifix [pal par] (easy ~))
    ==
  ==
++  cook-builtin-fn-parameter
  |=  parsed=*
  ^-  literal-value:ast
  ?:  ?=([@ @] parsed)
    [%literal-value dime=`dime`parsed]
  ~|("unexpected value: {<parsed>}" !!)
++  cook-builtin-fn-optional-parameter
  |=  parsed=*
  ^-  (unit literal-value:ast)
  ?~  parsed
    ~
  (some (cook-builtin-fn-parameter parsed))
++  parse-unary-scalar-fn
  |*  [fn-name=@tas first-param=rule]
  ;~  plug
    (cold fn-name (jester fn-name))
    ;~  pfix
      whitespace 
      %+  ifix
        [pal par]
      ;~  pose
        (ifix [whitespace whitespace] first-param) 
        :: TODO maybe we don't need these
        ;~(pfix whitespace first-param)
        ;~(sfix first-param whitespace)
      ==
    ==
  ==
++  parse-binary-scalar-fn
  |*  [fn-name=@tas first-param=rule second-param=rule]
  ;~  plug
    (cold fn-name (jester fn-name))
    ;~  pfix
      whitespace 
    %+  ifix
      [pal par]
      ;~  (glue com)
        ;~  pose
          (ifix [whitespace whitespace] first-param) 
          :: TODO maybe we don't need these
          ;~(pfix whitespace first-param)
          ;~(sfix first-param whitespace)
        ==
        ;~  pose
          (ifix [whitespace whitespace] second-param) 
          :: TODO maybe we don't need these
          ;~(pfix whitespace second-param)
          ;~(sfix second-param whitespace)
        ==
      ==
    ==
  ==
++  cook-ternary-builtin-fn
  |=  parsed=*
  ~|  "cook-ternary-builtin-fn not implemented: {<parsed>}"  !!
++  parse-ternary-scalar-fn
  |*  [fn-name=@tas first-param=rule second-param=rule third-param=rule]
  ;~  plug
    (cold fn-name (jester fn-name))
    ;~  pfix
      whitespace 
    %+  ifix
      [pal par]
      ;~  (glue com)
        ;~  pose
          (ifix [whitespace whitespace] first-param)
          :: TODO maybe we don't need these
          ;~(pfix whitespace first-param)
          ;~(sfix first-param whitespace)
        ==
        ;~  pose
          :: TODO maybe we don't need these
          (ifix [whitespace whitespace] second-param) 
          ;~(pfix whitespace second-param)
          ;~(sfix second-param whitespace)
        ==
        ;~  pose
          (ifix [whitespace whitespace] third-param) 
          :: TODO maybe we don't need these
          ;~(pfix whitespace third-param)
          ;~(sfix third-param whitespace)
        ==
      ==
    ==
  ==
++  cook-n-ary-builtin-fn
  |=  parsed=*
  ~|  "cook-n-ary-builtin-fn not implemented: {<parsed>}"  !!
++  parse-n-ary-scalar-fn
  |*  [fn-name=@tas parse-params=rule]
  ;~  plug
    (cold fn-name (jester fn-name))
    ;~  pfix
      whitespace
      %+  ifix
        [pal par]
      %+  more
        com
      ;~  pose
        (ifix [whitespace whitespace] parse-params) 
        ;~(pfix whitespace parse-params)
        ;~(sfix parse-params whitespace)
      ==
    ==
  ==
::
++  parse-quoted-string  (ifix [soq soq] (star mixed-case-symbol))
++  parse-builtin-scalar-fn
  ;~  pose
    (parse-nullary-scalar-fn %getdate)
    (parse-nullary-scalar-fn %sysdatetimeoffset)
    (parse-unary-scalar-fn %day parse-value-literal)
    (parse-unary-scalar-fn %month parse-value-literal)
    (parse-unary-scalar-fn %year parse-value-literal)
    (parse-unary-scalar-fn %abs parse-value-literal)
    (parse-unary-scalar-fn %floor parse-value-literal)
    (parse-unary-scalar-fn %ceiling parse-value-literal)
    (parse-unary-scalar-fn %sign parse-value-literal)
    (parse-unary-scalar-fn %sqrt parse-value-literal)
    (parse-unary-scalar-fn %len parse-value-literal)
    (parse-binary-scalar-fn %log parse-value-literal parse-value-literal)
    (parse-unary-scalar-fn %log parse-value-literal)
    (parse-binary-scalar-fn %power parse-value-literal parse-value-literal)
    (parse-binary-scalar-fn %left parse-value-literal parse-value-literal)
    (parse-binary-scalar-fn %right parse-value-literal parse-value-literal)
    (parse-binary-scalar-fn %trim parse-value-literal parse-value-literal)
    (parse-unary-scalar-fn %trim parse-value-literal)
    (parse-ternary-scalar-fn %round parse-value-literal parse-value-literal parse-value-literal)
    (parse-binary-scalar-fn %round parse-value-literal parse-value-literal)
    (parse-ternary-scalar-fn %substring parse-value-literal parse-value-literal parse-value-literal)
    (parse-n-ary-scalar-fn %concat parse-value-literal)
  ==
::
++  cook-scalar-param
  |=  parsed=*
  ^-  scalar-param
  ?:  ?=([%alias *] parsed)
    [%unknown-alias (cook-scalar-alias +.parsed)]
  ?:  ?=([%literal [@ @]] parsed)
    [%literal `dime`+.parsed]
  ?:  ?=(@ parsed)  [%unqualified-column name=parsed alias=~]
    :::*  %one-item-qualifier
    ::  column=parsed
    ::==
  ?:  ?=([@ @] parsed)
    :*  %two-item-qualifier
      alias=-.parsed
      column=+.parsed
    ==

  ?:  ?=([@ @ @ @] parsed)
      %:  qualified-column:ast
          %qualified-column
          %:  qualified-table:ast
              %qualified-table
              ship=~
              database=?~(-.parsed default-database -.parsed)
              namespace=?~(+<.parsed %dbo +<.parsed)
              table=+>-.parsed
              alias=~
              ==
          column=+>+.parsed
          alias=~
          ==

  ?:  ?=([@ @ @ @ @] parsed)
    %:  qualified-column:ast
        %qualified-column
        %:  qualified-table:ast
            %qualified-table
            ship=(some -.parsed)
            database=?~(+<.parsed default-database +<.parsed)
            namespace=?~(+>-.parsed %dbo +>-.parsed)
            table=+>+<.parsed
            alias=~
            ==
        column=+>+>.parsed
        alias=~
        ==
  !!  :: this should never be reached
++  get-datum-for-predicate
  ;~  pose
    ;~(sfix parse-qualified-column whitespace)
    ;~(sfix parse-value-literal whitespace)
    ;~(sfix parse-datum-for-predicate whitespace)
    parse-datum-for-predicate
  ==
++  get-scalar-param  ~+
  ;~  pose
    ;~(sfix parse-qualifier whitespace)
    ::;~(sfix parse-qualified-column whitespace)
    (stag %literal ;~(sfix parse-value-literal whitespace))
    (stag %alias ;~(sfix mixed-case-symbol whitespace))
    ;~(sfix parse-scalar-param whitespace)
    parse-scalar-param
  ==
++  cook-if
  |=  parsed=*
  ^-  if-then-else-helper
  =/  raw-then  +>-.parsed
  =/  cooked-then  (cook-scalar-param raw-then)
  =/  raw-else  +>+>-.parsed
  =/  cooked-else  (cook-scalar-param raw-else)
  %:  if-then-else-helper
    %if-then-else-helper
    (produce-predicate (predicate-list -.parsed))
    cooked-then
    cooked-else
  ==
++  parse-if
  ;~  plug
    parse-predicate
    ;~(pfix whitespace (cold %then (jester 'then')))
    ;~(pose parse-scalar-param)
    ;~(pfix whitespace (cold %else (jester 'else')))
    ;~(pose parse-scalar-param)
    ;~(pfix whitespace (cold %endif (jester 'endif')))
  ==
++  parse-when-then
  ;~  plug
    ;~(pfix whitespace (cold %when (jester 'when')))
    ;~(pose parse-predicate parse-scalar-param)
    ;~(pfix whitespace (cold %then (jester 'then')))
    ;~(pose parse-aggregate parse-scalar-param)
  ==
++  parse-case-else
  ;~  plug
    ;~(pfix whitespace (cold %else (jester 'else')))
    ;~(pfix whitespace ;~(pose parse-aggregate parse-scalar-param))
    ;~(pfix whitespace (cold %end (jester 'end')))
  ==
++  cook-case-body
  |=  parsed=*
  ~+
  =/  cooked-target  (cook-scalar-param -.parsed)
  =/  case-when-then-list  +<.parsed
  =/  cases
    |-
    ^-  (list case-when-then-helper)
    ?~  case-when-then-list
      ~
    =/  raw-when  ->-.case-when-then-list
    =/  raw-then  ->+>.case-when-then-list
    =/  cooked-when  (produce-predicate (predicate-list raw-when))
    =/  cooked-then  (cook-scalar-param raw-then)
    =/  cooked-case-when-then
      (case-when-then-helper %case-when-then-helper cooked-when cooked-then)
    [cooked-case-when-then $(case-when-then-list +.case-when-then-list)]
  ?@  +>.parsed
    ?:  =(+>.parsed %end)
      (case-helper %case-helper cooked-target (flop cases) ~)
    ~|("cannot parse case: unexpected atom: {<+>.parsed>}" !!)
  ?:  =(%else +>-.parsed)
    =/  raw-else  +>+<.parsed
    =/  cooked-else  (cook-scalar-param raw-else)
    (case-helper %case-helper cooked-target (flop cases) (some cooked-else))
  ~|("cannot cook case: unexpected atom: {<+>-.parsed>}" !!)
++  parse-case
  ;~  plug
    parse-scalar-param
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
    ;~  pfix
      whitespace
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
    parse-scalar-param
  ==
++  cook-coalesce
  |=  parsed=*
  ^-  coalesce-helper
  =/  coalesce-params
    |-
    ^-  (list scalar-param)
    ?~  parsed
      ~
    [(cook-scalar-param -.parsed) $(parsed +.parsed)]
  %:  coalesce-helper
    %coalesce-helper
    data=coalesce-params
  ==
++  parse-coalesce  ~+
  (parse-n-ary-scalar-fn %coalesce ;~(pose parse-aggregate parse-scalar-param))
++  parse-math
  ;~  plug
    (cold %begin (jester 'begin'))
    (star scalar-token)
  ==
++  parse-scalar-body
  ;~  pose
    ;~(plug (cold %if (jester 'if')) parse-if)
    ;~(plug (cold %case (jester 'case')) parse-case)
    parse-coalesce
    parse-builtin-scalar-fn
    parse-math
  ==
++  scalar-stop  ;~
  pose
    ;~(plug whitespace (jest ')'))
    ;~(plug whitespace (jester 'where'))
    ;~(plug whitespace (jester 'select'))
    ;~(plug whitespace (jester 'else'))
    ;~(plug whitespace (jester 'endif'))
    ;~(plug whitespace (jester 'end'))
  ==
++  scalar-body  ;~(pfix whitespace parse-scalar-body)
++  cook-scalar-alias
  |=  parsed=*
  ?:  ?=([%lower-case @] parsed)
    `@t`+.parsed
  ?:  ?=([%mixed-case @] parsed)
    =/  sanitized  (crip (cass (trip +.parsed)))
    ?:  ((sane %t) sanitized)
      `@t`sanitized
    ~|("cook-scalar-alias: can't cast {<sanitized>} to @t" !!)
  !!
++  parse-scalar-alias  ~+
  ;~  pose
    (stag %lower-case ;~(pfix whitespace sym))
    (stag %mixed-case ;~(pfix whitespace mixed-case-symbol))
  ==
++  parse-scalar
  ;~  plug
      parse-scalar-alias        :: scalar alias
      scalar-body               :: scalar function invocation
  ==
++  parse-scalars
  ;~  plug
      (cold %scalars ;~(pfix whitespace (jester 'scalars')))
      (star parse-scalar)
    ==
::
::  select
::
++  parse-alias-all  ~+
  (stag %all-columns ;~(sfix parse-alias ;~(plug dot tar)))
++  parse-object-all  ~+
  (stag %all-columns ;~(sfix parse-qualified-table ;~(plug dot tar)))
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
++  select-column  ~+
  ;~  pose
    (ifix [whitespace whitespace] parse-selection)
    ;~(plug whitespace parse-selection)
    parse-selection
  ==
++  select-columns  ~+
  ;~  pose
    (more com select-column)
    select-column
  ==
++  select-top  ~+
  ;~  plug
    (cold %top ;~(plug whitespace (jester 'top')))
    ;~(pfix whitespace dem)
    select-columns
  ==
++  parse-select  ~+
  ;~  plug
    (cold %select ;~(plug whitespace (jester 'select')))
    ;~  pose
      select-top
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
:: TODO: this is only called twice now, inline
++  finalize-qualifier
  |=  [a=qualifier alias-map=(map @t qualified-table:ast)]
  ^-  datum-or-scalar:ast
  ::?:  ?=(qualified-column:ast a)    a
  ::?:  ?=(unqualified-column:ast a)  a
  ?:  ?=([%two-item-qualifier *] a)
    %:  qualified-column:ast
      %qualified-column
      table=(~(got by alias-map) (crip (cass (trip alias.a))))
      column=column.a
      alias=~
    ==
  a
::
::  helper types
::
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
+$  interim-key
  $:
    %interim-key
    columns=(list ordered-column:ast)
  ==
+$  parens        ?(%pal %par)
+$  raw-pred-cmpnt  ?(parens predicate-component:ast)
+$  group-by-list  (list grouping-column:ast)
+$  order-by-list  (list ordering-column:ast)
+$  pred-folder-state
  $:
    displ=@
    level=@
    cmpnt=(unit raw-pred-cmpnt)
    cmpnt-displ=@
    the-list=(list raw-pred-cmpnt)
  ==
+$  select-mold-1
  $:
    $:  %selected-aggregate
        @
        %qualified-column
        [%qualified-table (unit @p) @ @ @ (unit @t)]
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
        [%qualified-table (unit @p) @ @ @ (unit @t)]
        @
        @
        ==
  ==
+$  unknown-alias  $:(%unknown-alias name=@t)
+$  scalar-param   $%(qualifier-or-literal qualifier unknown-alias)
+$  qualifier-or-literal
  $%  qualifier
      $:(%literal dime)
  ==
+$   qualifier
  $%  two-item-qualifier
      qualified-column:ast
      unqualified-column:ast
  ==
+$  two-item-qualifier
  $:
     %two-item-qualifier
     alias=@t               :: table or view alias
     column=@tas
  ==
+$  scalar-helper
  $%  coalesce-helper
     if-then-else-helper
     case-helper
  ==
+$  coalesce-helper
  $:
    %coalesce-helper
    data=(list scalar-param)
  ==
+$  if-then-else-helper
  $:
    %if-then-else-helper
    if=predicate:ast
    then=scalar-param
    else=scalar-param
  ==
+$  case-helper
  $:
    %case-helper
    target=scalar-param
    cases=(list case-when-then-helper)
    else=(unit scalar-param)
  ==
+$  case-when-then-helper
  $:
    %case-when-then-helper
    when=predicate:ast
    then=scalar-param
  ==
--
