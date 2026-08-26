/-  *server-state-1, server-state-1, server-state-0, *obelisk, ast=obelisk-ast
/+  default-agent, dbug, *format, *main, *migration, *print, scry
|%
+$  versioned-state
  $%  state-0
      state-1
      state-2
  ==
+$  state-0
  $:  %0
      server=server:server-state-0
  ==
+$  state-1
  $:  %1
      =server
  ==
+$  state-2
  $:  %2
      =server
  ==
+$  card  card:agent:gall
--
%-  agent:dbug
=|  state-2
=*  state  -
^-  agent:gall
|_  =bowl:gall
+*  this  .
    default  ~(. (default-agent this %n) bowl)
++  on-init
  ^-  (quip card _this)
  =+  [our=(scot %p our.bowl) now=(scot %da now.bowl)]
  =/  animal-cards=(list card)
    :~  :*  %pass
            /init/animal-shelter
            %arvo
            %c
            %warp
            our.bowl
            q.byk.bowl
            ~
            %sing
            %x
            da+now.bowl
            /gen/animal-shelter/all-animal-shelter/txt
            ==
        ==
  :_  this(state *state-2)
  animal-cards
++  on-save
  !>(state)
++  on-load
  |=  old-state=vase
  ^-  (quip card _this)
  ::  attempt state reload/migration
  ::
  =/  r=(each state-2 tang)
    %-  mule  |.
              =/  old  !<(versioned-state old-state)
              ?-  -.old
                %0
                  =/  migrated
                    (migrate-server-0-to-1 server.old)
                  [%2 (migrate-server-1-to-2 migrated)]
                %1  [%2 (migrate-server-1-to-2 server.old)]
                %2  old
                ==
  ::  if it succeeded, use the old state
  ::
  ?:  ?=(%.y -.r)  `this(state p.r)
  ::  if it failed, bunt the correct state type
  ::
  %-  (slog 'old state corrupt, unable to migrate data' ~)
  `this(state *state-2)
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?>  ?=(%obelisk-action mark)
  =/  act  !<(action vase)
  ::
  =/  state-server  process-cmds(state server, bowl bowl)
  =/  deprecated
        |=  [default-database=@tas urql=tape print-results=?]
        ^-  (quip card _this)
        =/  virtualized
              ^-  (each (pair (list cmd-result) server:server-state-1) tang)
              %-  mule
              |.
              (state-server (parse-urql default-database urql))
        ?-  -.virtualized
          %.n
            =/  dummy
              ?:  print-results
                (print-crash p.virtualized)
              ~
            :_  this
            :~  [%give %fact ~[/server] %noun !>([| p.virtualized])]
                [%give %kick ~[/server] ~]
            ==
          %.y
            =/  res  p.virtualized
            =/  dummy
              ?:  print-results
                (print -.res)
              ~
            =/  out  (format-results %vector -.res)
            :_  this(server +.res)
            :~  [%give %fact ~[/server] %noun !>([& out])]
                [%give %kick ~[/server] ~]
            ==
        ==
  ::
  ?-    -.act
  ::
  %script
    =/  virtualized
      ^-  (each (pair (list cmd-result) server:server-state-1) tang)
      %-  mule
      |.
      =/  res
        (state-server (parse-urql default-database.act urql.act))
      [(format-results format.act -.res) +.res]
    ?-  -.virtualized
      %.n
        :_  this
        :~  [%give %fact ~[/server] %noun !>([| p.virtualized])]
            [%give %kick ~[/server] ~]
            ==
      %.y
        =/  res  p.virtualized
        :_  this(server +.res)
        :~  [%give %fact ~[/server] %noun !>([& -.res])]
            [%give %kick ~[/server] ~]
            ==
    ==
  ::
  %cmd-list
    =/  virtualized
      ^-  (each (pair (list cmd-result) server:server-state-1) tang)
      %-  mule
      |.
      =/  res  (state-server cmds.act)
      [(format-results format.act -.res) +.res]
    ?-  -.virtualized
      %.n
        :_  this
        :~  [%give %fact ~[/server] %noun !>([| p.virtualized])]
            [%give %kick ~[/server] ~]
            ==
      %.y
        =/  res  p.virtualized
        :_  this(server +.res)
        :~  [%give %fact ~[/server] %noun !>([& -.res])]
            [%give %kick ~[/server] ~]
            ==
    ==

  ::
  %tape-print
    ::  prints results
    (deprecated +<.act +>.act %.y)
  ::
  %tape
    ::  action without printing results
    (deprecated +<.act +>.act %.n)
  ::
  %parse
    =/  virtualized
      ^-  (each (list command) tang)
      %-  mule
      |.
      ::~>  %bout.[0 %parse-cmds]
      (parse-urql +<.act +>.act)
    ?-  -.virtualized
      %.n
        :_  this
            :~  [%give %fact ~[/server] %noun !>([| p.virtualized])]
                [%give %kick ~[/server] ~]
                ==
      %.y
        :_  this
            :~  [%give %fact ~[/server] %noun !>([& p.virtualized])]
                [%give %kick ~[/server] ~]
                ==
    ==
  ::
  %commands
    =/  res  (state-server +.act)
    =/  out  (format-results %vector -.res)
    :_  this(server +.res)
        :~  [%give %fact ~[/server] %noun !>(out)]
            [%give %kick ~[/server] ~]
            ==
  ::
  ::  for testing with expect-fail-message
  %test
    =/  res2  %:  state-server
                  ::~>  %bout.[0 %parse-cmds]
                  (parse-urql +<.act +>.act)
                  ==
    :_  this(server +.res2)
    :~  [%give %fact ~[/server] %noun !>(-.res2)]
        [%give %kick ~[/server] ~]
    ==
  ==
++  on-watch
  ::  /obelisk paths resolve one query, give its result, and kick;
  ::  the query runs through +process-cmds security in /lib/main
  |=  =path
  ^-  (quip card _this)
  ?.  ?=([%obelisk ^] path)  `this
  =/  res=(unit (unit cage))
    (~(peek scry [server bowl]) t.path)
  ?~  res
    ~|("invalid obelisk subscription path {<path>}" !!)
  ?~  u.res
    ~|("invalid obelisk subscription path {<path>}" !!)
  :_  this
      :~  [%give %fact ~ u.u.res]
          [%give %kick ~ ~]
          ==
++  on-leave  on-leave:default
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ?+  path  [~ ~]
    [%x %server ~]   ``noun+!>(server.state)
    [%x %obelisk ^]  (~(peek scry [server bowl]) t.t.path)
  ==
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+    wire  (on-agent:default wire sign)
      [%init %animal-shelter %poke ~]
    `this
  ::
  ==
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
  ?+    wire  (on-arvo:default wire sign-arvo)
      [%init %animal-shelter ~]
    ?+    -.sign-arvo  (on-arvo:default wire sign-arvo)
        %clay
      ?+    -.+.sign-arvo  (on-arvo:default wire sign-arvo)
          %writ
        =/  riot=riot:clay  +.+.sign-arvo
        ?~  riot
          %-  (slog 'animal-shelter init import file not found' ~)
          `this
        =/  cage  r.u.riot
        ?.  ?=(%txt p.cage)
          %-  (slog 'animal-shelter init import expected %txt cage' ~)
          `this
        =/  txt  !<(wain q.cage)
        :_  this
        :~  :*  %pass
                /init/animal-shelter/poke
                %agent
                [our.bowl dap.bowl]
                %poke
                %obelisk-action
                !>  :*  %script
                        %animal-shelter
                        %raw
                        (reel txt |=([a=cord b=tape] (weld (trip a) b)))
                        ==
            ==
        ==
      ==
    ==
  ==
++  on-fail   on-fail:default
--
