/-  *server-state-1, server-state-1, server-state-0, *obelisk, ast
/+  default-agent, dbug, *main, *migration, *print
|%
+$  versioned-state
  $%  state-0
      state-1
  ==
+$  state-0
  $:  %0
      server=server:server-state-0
  ==
+$  state-1
  $:  %1
      =server
  ==
+$  card  card:agent:gall
--
%-  agent:dbug
=|  state-1
=*  state  -
^-  agent:gall
|_  =bowl:gall
+*  this  .
    default  ~(. (default-agent this %n) bowl)
++  on-init
  ^-  (quip card _this)
  =+  [our=(scot %p our.bowl) now=(scot %da now.bowl)]
  =+  .^(dudes=(set [dude:gall ?]) %ge our %base now /$)
  =/  install-hawk=card
    :*  %pass
        /init/hawk/install
        %agent
        [our.bowl %hood]
        %poke
        %kiln-install
        !>([%hawk ~dister-migrev-dolseg %hawk])
    ==
  =/  hawk-cards=(list card)
    ?:  |((~(has in dudes) [%hawk &]) (~(has in dudes) [%hawk |]))
      ~
    [install-hawk ~]
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
  :_  this(state *state-1)
  (weld hawk-cards animal-cards)
++  on-save
  !>(state)
++  on-load
  |=  old-state=vase
  ^-  (quip card _this)
  ::  attempt state reload/migration
  ::
  =/  r=(each state-1 tang)
    %-  mule  |.
    =/  old  !<(versioned-state old-state)
    ?-  -.old
      %0  [%1 (migrate-server-0-to-1 server.old)]
      %1  old
    ==
  ::  if it succeeded, use the old state
  ::
  ?:  ?=(%.y -.r)  `this(state p.r)
  ::  if it failed, bunt the correct state type
  ::
  %-  (slog 'old state corrupt, unable to migrate data' ~)
  `this(state *state-1)
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?>  ?=(%obelisk-action mark)
  =/  act  !<(action vase)
  ::
  =/  state-server  process-cmds(state server, bowl bowl)
  ::
  ?-    -.act
  ::
  ::  prints results
  %tape
    =/  virtualized
        ^-  (each (pair (list cmd-result) server:server-state-1) tang)
        %-  mule
          |.
          %:  state-server
          ::::~>  %bout.[0 %parse-cmds]
          (parse-urql +<.act +>.act)
          ==
    ?-  -.virtualized
      %.n
        :_  this
        :~  [%give %fact ~[/server] %noun !>([| p.virtualized])]
            [%give %kick ~[/server] ~]
        ==
      %.y
        =/  res  p.virtualized
        =/  x  (print -.res)
        :_  this(server +.res)
        :~  [%give %fact ~[/server] %noun !>([& -.res])]
            [%give %kick ~[/server] ~]
        ==
    ==
  ::
  ::  action without printing results
  %tape2
    =/  virtualized
      ^-  (each (pair (list cmd-result) server:server-state-1) tang)
      %-  mule
      |.
      %:  state-server
      ::~>  %bout.[0 %parse-cmds]
      (parse-urql +<.act +>.act)
      ==
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
  %parse
    =/  virtualized
      ^-  (each (list command) tang)
      %-  mule
      |.
      ::~>  %bout.[0 %parse-cmds]
      (parse-urql +<.act +>.act)
    ?-  -.virtualized
      %.n
        ~&  "{<(slog p.virtualized)>}"
        :_  this
        :~  [%give %fact ~[/server] %noun !>([| p.virtualized])]
            [%give %kick ~[/server] ~]
        ==
      %.y
        ~&  "{<p.virtualized>}"
        :_  this
        :~  [%give %fact ~[/server] %noun !>([& p.virtualized])]
            [%give %kick ~[/server] ~]
        ==
    ==
  ::
  %commands
    =/  res  (state-server +.act)
    :_  this(server +.res)
    :~  [%give %fact ~[/server] %noun !>(-.res)]
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
++  on-watch  |=(=path `this)
++  on-leave  on-leave:default
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ?+  path  [~ ~]
    [%x %server ~]  ``noun+!>(server.state)
  ==
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+    wire  (on-agent:default wire sign)
      [%init %animal-shelter %poke ~]
    `this
  ::
      [%init %hawk %install ~]
    `this
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
                !>([%tape2 %animal-shelter (reel txt |=([a=cord b=tape] (weld (trip a) b)))])
            ==
        ==
      ==
    ==
  ==
++  on-fail   on-fail:default
--
