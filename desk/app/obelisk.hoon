/-  *server-state, server-state, *obelisk, ast
/+  default-agent, dbug, *server, *print
|%
+$  versioned-state
  $%  state-0
  ==
+$  state-0
  $:  %0
      =server
  ==
+$  card  card:agent:gall
--
%-  agent:dbug
=|  state-0
=*  state  -
^-  agent:gall
|_  =bowl:gall
+*  this  .
    default  ~(. (default-agent this %n) bowl)
++  on-init  `this(state *state-0)
++  on-save   !>(state)
++  on-load
  |=  old-state=vase
  ^-  (quip card _this)
  ::  attempt state reload/migration
  ::
  =/  r=(each state-0 tang)
    %-  mule  |.
    =/  old  !<(versioned-state old-state)
    ?-  -.old
      %0  old
      :: %1
    ==
  ::  if it succeeded, use the old state
  ::
  ?:  ?=(%.y -.r)  `this(state p.r)
  ::  if it failed, bunt the correct state type
  ::
  %-  (slog 'old state corrupt, unable to migrate data' ~)
  `this(state *state-0)
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
    :: uncomment in order to stop on parse error
    ::=/  xx  (parse-urql(state server, bowl bowl) +<.act +>.act)
    =/  virtualized
        ^-  (each (pair (list cmd-result) server:server-state) tang)
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
    :: uncomment in order to stop on parse error
    ::=/  xx  (parse-urql(state server, bowl bowl) +<.act +>.act)
    =/  virtualized
      ^-  (each (pair (list cmd-result) server:server-state) tang)
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
++  on-agent  on-agent:default
++  on-arvo   on-arvo:default
++  on-fail   on-fail:default
--
