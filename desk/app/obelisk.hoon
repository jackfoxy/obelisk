/-  *obelisk, ast
/+  default-agent, dbug, *obelisk, *print
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
    =/  res  %:  state-server
                 ::~>  %bout.[0 %parse-cmds]
                 (parse-urql +<.act +>.act)
                 ==


    =/  x  (print -.res)


    :_  this(server +.res)
    :~  [%give %fact ~[/server] %obelisk-result !>(-.res)]
        [%give %kick ~[/server] ~]
    ==
  ::
  %commands
    =/  res  (state-server +.act)
    :_  this(server +.res)
    :~  [%give %fact ~[/server] %obelisk-result !>(-.res)]
        [%give %kick ~[/server] ~]
    ==
  ==
++  on-watch  on-watch:default
++  on-leave  on-leave:default
++  on-peek   on-peek:default
++  on-agent  on-agent:default
++  on-arvo   on-arvo:default
++  on-fail   on-fail:default
--
