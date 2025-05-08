/-  *obelisk, obelisk, ast
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
  |=  =old==vase
  ^-  (quip card _this)
  =/  old  !<(versioned-state old-vase)
  |-
  ?-  -.old
    %0  `this(state old)
    ::  $(old [%1 +.old])
    ::  %1  `this(state old)
  ==
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
  %tape
    =/  virtualized
      ^-  (each (pair (list cmd-result:obelisk) server:obelisk) tang)
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
        =/  x  (print -.res)
        :_  this(server +.res)
        :~  [%give %fact ~[/server] %noun !>([& -.res])]
            [%give %kick ~[/server] ~]
        ==
    ==
  ::
  ::  for testing without printing results
  %tape2
    =/  virtualized
      ^-  (each (pair (list cmd-result:obelisk) server:obelisk) tang)
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
                                                       ::=/  x  (print -.res2)
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
